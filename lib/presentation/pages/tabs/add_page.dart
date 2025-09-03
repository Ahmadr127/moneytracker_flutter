import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/services/transaction_service.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => AddPageState();
}

class AddPageState extends State<AddPage> {
  final TransactionService _service = TransactionService();

  TransactionType _selectedType = TransactionType.income;
  List<WalletModel> _wallets = [];
  List<CategoryModel> _categories = [];
  WalletModel? _selectedWallet;
  WalletModel? _selectedToWallet; // for transfer
  CategoryModel? _selectedCategory; // income/expense
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      final wallets = await _service.getWallets();
      final categories = await _service.getCategories(type: _selectedType);
      setState(() {
        _wallets = wallets;
        _categories = categories;
        _selectedWallet = wallets.isNotEmpty ? wallets.first : null;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Expose refresh for parent to call
  Future<void> refresh() async {
    await _loadInitial();
  }

  Future<void> _reloadCategories() async {
    try {
      final categories = await _service.getCategories(type: _selectedType);
      setState(() {
        _categories = categories;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
      });
    } catch (_) {}
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_selectedWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet terlebih dahulu')),
      );
      return;
    }
    if (_selectedType == TransactionType.transfer && _selectedToWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet tujuan')),
      );
      return;
    }
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final tx = TransactionModel(
        id: 'new',
        userId: '', // biarkan kosong; user_id akan diisi otomatis oleh trigger/RLS di Supabase
        type: _selectedType,
        amount: amount,
        walletId: _selectedWallet!.id,
        toWalletId: _selectedType == TransactionType.transfer ? _selectedToWallet?.id : null,
        categoryId: _selectedType != TransactionType.transfer ? _selectedCategory?.id : null,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        date: _selectedDate,
      );
      await _service.createTransaction(tx);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan')),
      );
      _amountController.clear();
      _noteController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Transaksi',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Pemasukan'),
                    selected: _selectedType == TransactionType.income,
                    onSelected: (v) {
                      if (!v) return;
                      setState(() => _selectedType = TransactionType.income);
                      _reloadCategories();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Pengeluaran'),
                    selected: _selectedType == TransactionType.expense,
                    onSelected: (v) {
                      if (!v) return;
                      setState(() => _selectedType = TransactionType.expense);
                      _reloadCategories();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Transfer'),
                    selected: _selectedType == TransactionType.transfer,
                    onSelected: (v) {
                      if (!v) return;
                      setState(() => _selectedType = TransactionType.transfer);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Amount
                      TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Nominal',
                          prefixText: 'Rp ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 12),
                      // Wallet From
                      DropdownButtonFormField<WalletModel>(
                        value: _selectedWallet,
                        items: _wallets
                            .map((w) => DropdownMenuItem(
                                  value: w,
                                  child: Text(w.name),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedWallet = v),
                        decoration: const InputDecoration(labelText: 'Dompet'),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedType == TransactionType.transfer)
                        DropdownButtonFormField<WalletModel>(
                          value: _selectedToWallet,
                          items: _wallets
                              .where((w) => w.id != _selectedWallet?.id)
                              .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedToWallet = v),
                          decoration: const InputDecoration(labelText: 'Dompet Tujuan'),
                        ),
                      if (_selectedType != TransactionType.transfer) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<CategoryModel>(
                          value: _selectedCategory,
                          items: _categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                          decoration: const InputDecoration(labelText: 'Kategori'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Tanggal: ${_selectedDate.toLocal().toString().split(' ').first}'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDate: _selectedDate,
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                            child: const Text('Pilih Tanggal'),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _submit,
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // removed unused _buildTransactionTypeCard
}
