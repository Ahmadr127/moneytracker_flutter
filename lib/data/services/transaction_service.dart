import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../config/constants.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final SupabaseClient _db = SupabaseClientWrapper.client;

  String _requireUserId() {
    final id = SupabaseClientWrapper.userId;
    if (id == null) {
      throw Exception('User belum login');
    }
    return id;
  }

  // Wallets
  Future<List<WalletModel>> getWallets() async {
    final userId = _requireUserId();
    final result = await _db
        .from(AppConstants.walletsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (result as List)
        .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WalletModel> createWallet({
    required String name,
    required WalletType type,
    double initialBalance = 0,
  }) async {
    final userId = _requireUserId();
    final data = {
      'user_id': userId,
      'name': name,
      'type': type.name,
      'balance': initialBalance,
      'created_at': DateTime.now().toIso8601String(),
    };
    final inserted = await _db
        .from(AppConstants.walletsTable)
        .insert(data)
        .select()
        .single();
    return WalletModel.fromJson(inserted);
  }

  Future<WalletModel> updateWalletBalance({
    required String walletId,
    required double newBalance,
  }) async {
    final updated = await _db
        .from(AppConstants.walletsTable)
        .update({'balance': newBalance})
        .eq('id', walletId)
        .select()
        .single();
    return WalletModel.fromJson(updated);
  }

  // Categories
  Future<List<CategoryModel>> getCategories({TransactionType? type}) async {
    final userId = _requireUserId();
    var query = _db
        .from(AppConstants.categoriesTable)
        .select()
        .eq('user_id', userId);
    if (type != null) {
      query = query.eq('type', type.name);
    }
    final result = await query.order('name');
    return (result as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel> createCategory({
    required String name,
    required TransactionType type,
  }) async {
    final userId = _requireUserId();
    final data = {
      'user_id': userId,
      'name': name,
      'type': type.name,
    };
    final inserted = await _db
        .from(AppConstants.categoriesTable)
        .insert(data)
        .select()
        .single();
    return CategoryModel.fromJson(inserted);
  }

  // Transactions
  Future<TransactionModel> createTransaction(TransactionModel tx) async {
    // Adjust wallet balances if needed
    await _applyBalanceEffects(tx, isCreate: true);

    final payload = Map<String, dynamic>.from(tx.toJson());
    payload.remove('id');
    // Never send user_id from client; let trigger/set_user_id or RLS handle it
    payload.remove('user_id');

    try {
      // Debug log
      // ignore: avoid_print
      print('📤 [TX][CREATE] Payload: $payload');
      final inserted = await _db
          .from(AppConstants.transactionsTable)
          .insert(payload)
          .select()
          .single();
      // ignore: avoid_print
      print('✅ [TX][CREATE] Inserted: $inserted');
      return TransactionModel.fromJson(inserted);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TX][CREATE] Error: $e');
      rethrow;
    }
  }

  Future<TransactionModel> updateTransaction(TransactionModel tx) async {
    // To properly adjust balances we need old transaction
    final existing = await _db
        .from(AppConstants.transactionsTable)
        .select()
        .eq('id', tx.id)
        .single();
    final old = TransactionModel.fromJson(existing);

    // Revert old effects, then apply new
    await _applyBalanceEffects(old, isCreate: false, revertOnly: true);
    await _applyBalanceEffects(tx, isCreate: false);

    final payload = Map<String, dynamic>.from(tx.toJson());
    // Do not allow changing user_id via client
    payload.remove('user_id');

    try {
      // ignore: avoid_print
      print('📤 [TX][UPDATE] ID: ${tx.id}, Payload: $payload');
      final updated = await _db
          .from(AppConstants.transactionsTable)
          .update(payload)
          .eq('id', tx.id)
          .select()
          .single();
      // ignore: avoid_print
      print('✅ [TX][UPDATE] Updated: $updated');
      return TransactionModel.fromJson(updated);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TX][UPDATE] Error: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    // Revert balance effects first
    try {
      final existing = await _db
          .from(AppConstants.transactionsTable)
          .select()
          .eq('id', id)
          .single();
      final old = TransactionModel.fromJson(existing);
      await _applyBalanceEffects(old, isCreate: false, revertOnly: true);
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [TX][DELETE] Failed reverting balances (maybe already missing): $e');
    }

    try {
      // ignore: avoid_print
      print('🗑️ [TX][DELETE] ID: $id');
      await _db.from(AppConstants.transactionsTable).delete().eq('id', id);
      // ignore: avoid_print
      print('✅ [TX][DELETE] Deleted');
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TX][DELETE] Error: $e');
      rethrow;
    }
  }

  Future<List<TransactionModel>> getTransactions({
    DateTime? start,
    DateTime? end,
    TransactionType? type,
    String? walletId,
    String? categoryId,
  }) async {
    final userId = _requireUserId();
    var query = _db
        .from(AppConstants.transactionsTable)
        .select()
        .eq('user_id', userId);

    if (start != null) {
      query = query.gte('date', start.toIso8601String());
    }
    if (end != null) {
      query = query.lte('date', end.toIso8601String());
    }
    if (type != null) {
      query = query.eq('type', type.name);
    }
    if (walletId != null) {
      query = query.eq('wallet_id', walletId);
    }
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    try {
      // ignore: avoid_print
      print('🔎 [TX][LIST] start=$start end=$end type=$type wallet=$walletId category=$categoryId');
      final result = await query.order('date', ascending: false);
      // ignore: avoid_print
      print('✅ [TX][LIST] Count: ${(result as List).length}');
      return result
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TX][LIST] Error: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> getTotals({
    required DateTime start,
    required DateTime end,
  }) async {
    final userId = _requireUserId();
    // ignore: avoid_print
    print('📊 [TX][TOTALS] start=$start end=$end');
    final rows = await _db
        .from(AppConstants.transactionsTable)
        .select('type, amount')
        .eq('user_id', userId)
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String());
    double income = 0;
    double expense = 0;
    for (final row in rows) {
      final t = (row['type'] as String?) ?? 'expense';
      final a = (row['amount'] as num).toDouble();
      if (t == 'income') {
        income += a;
      } else if (t == 'expense') {
        expense += a;
      }
    }
    // ignore: avoid_print
    print('✅ [TX][TOTALS] income=$income expense=$expense balance=${income - expense}');
    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  Future<Map<String, double>> getCategoryBreakdown({
    required DateTime start,
    required DateTime end,
    required TransactionType type,
  }) async {
    final userId = _requireUserId();
    // ignore: avoid_print
    print('🥧 [TX][BREAKDOWN] start=$start end=$end type=${type.name}');
    final rows = await _db
        .from(AppConstants.transactionsTable)
        .select('category_id, amount')
        .eq('user_id', userId)
        .eq('type', type.name)
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String());
    final Map<String, double> totals = {};
    for (final row in rows) {
      final key = (row['category_id'] as String?) ?? 'uncategorized';
      totals[key] = (totals[key] ?? 0) + (row['amount'] as num).toDouble();
    }
    // ignore: avoid_print
    print('✅ [TX][BREAKDOWN] ${totals.length} categories');
    return totals;
  }

  Future<void> _applyBalanceEffects(
    TransactionModel tx, {
    required bool isCreate,
    bool revertOnly = false,
  }) async {
    // When reverting, invert the sign compared to creation
    final factor = (isCreate && !revertOnly) ? 1.0 : -1.0;

    if (tx.type == TransactionType.income) {
      await _adjustWallet(tx.walletId, tx.amount * factor);
    } else if (tx.type == TransactionType.expense) {
      await _adjustWallet(tx.walletId, -tx.amount * factor);
    } else if (tx.type == TransactionType.transfer) {
      if (tx.toWalletId == null) return;
      await _adjustWallet(tx.walletId, -tx.amount * factor);
      await _adjustWallet(tx.toWalletId!, tx.amount * factor);
    }
  }

  Future<void> _adjustWallet(String walletId, double delta) async {
    final row = await _db
        .from(AppConstants.walletsTable)
        .select('balance')
        .eq('id', walletId)
        .single();
    final current = (row['balance'] as num?)?.toDouble() ?? 0;
    final next = current + delta;
    await _db
        .from(AppConstants.walletsTable)
        .update({'balance': next})
        .eq('id', walletId);
  }
}


