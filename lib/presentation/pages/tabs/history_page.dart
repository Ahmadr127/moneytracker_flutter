import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/services/transaction_service.dart';
import '../../../core/utils/currency_formatter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  final TransactionService _service = TransactionService();
  final ScrollController _scrollController = ScrollController();

  TransactionType? _filterType;
  DateTimeRange? _range;
  bool _loading = false;
  List<TransactionModel> _items = [];

  // Removed summary calculations to avoid unused getters after design change

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      DateTime? start;
      DateTime? end;
      if (_range != null) {
        start = DateTime(_range!.start.year, _range!.start.month, _range!.start.day);
        end = DateTime(_range!.end.year, _range!.end.month, _range!.end.day, 23, 59, 59);
      }
      final list = await _service.getTransactions(
        start: start,
        end: end,
        type: _filterType,
      );
      setState(() => _items = list);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat riwayat: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Expose refresh for parent
  Future<void> refresh() async {
    await _fetch();
  }

  Future<void> _delete(TransactionModel tx) async {
    try {
      await _service.deleteTransaction(tx.id);
      await _fetch();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header moved to AppBar
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Builder(builder: (context) {
                    final bool selected = _filterType == null;
                    final Color selColor = Theme.of(context).colorScheme.primary;
                    return FilterChip(
                      showCheckmark: false,
                      label: Text('Semua', style: TextStyle(color: selected ? selColor : null)),
                      avatar: Icon(Icons.all_inbox, size: 18, color: selected ? selColor : Theme.of(context).iconTheme.color),
                      selected: selected,
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(context).cardColor,
                      shape: StadiumBorder(side: BorderSide(color: selected ? selColor : Theme.of(context).dividerColor)),
                      onSelected: (v) {
                        setState(() => _filterType = null);
                        _fetch();
                      },
                    );
                  }),
                  Builder(builder: (context) {
                    final bool selected = _filterType == TransactionType.income;
                    const selColor = Colors.green;
                    return FilterChip(
                      showCheckmark: false,
                      label: Text('Pemasukan', style: TextStyle(color: selected ? selColor : null)),
                      avatar: Icon(Icons.trending_up, size: 18, color: selected ? selColor : Theme.of(context).iconTheme.color),
                      selected: selected,
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(context).cardColor,
                      shape: StadiumBorder(side: BorderSide(color: selected ? selColor : Theme.of(context).dividerColor)),
                      onSelected: (v) {
                        setState(() => _filterType = v ? TransactionType.income : null);
                        _fetch();
                      },
                    );
                  }),
                  Builder(builder: (context) {
                    final bool selected = _filterType == TransactionType.expense;
                    const selColor = Colors.red;
                    return FilterChip(
                      showCheckmark: false,
                      label: Text('Pengeluaran', style: TextStyle(color: selected ? selColor : null)),
                      avatar: Icon(Icons.trending_down, size: 18, color: selected ? selColor : Theme.of(context).iconTheme.color),
                      selected: selected,
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(context).cardColor,
                      shape: StadiumBorder(side: BorderSide(color: selected ? selColor : Theme.of(context).dividerColor)),
                      onSelected: (v) {
                        setState(() => _filterType = v ? TransactionType.expense : null);
                        _fetch();
                      },
                    );
                  }),
                  Builder(builder: (context) {
                    final bool selected = _filterType == TransactionType.transfer;
                    const selColor = Colors.blue;
                    return FilterChip(
                      showCheckmark: false,
                      label: Text('Transfer', style: TextStyle(color: selected ? selColor : null)),
                      avatar: Icon(Icons.swap_horiz, size: 18, color: selected ? selColor : Theme.of(context).iconTheme.color),
                      selected: selected,
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(context).cardColor,
                      shape: StadiumBorder(side: BorderSide(color: selected ? selColor : Theme.of(context).dividerColor)),
                      onSelected: (v) {
                        setState(() => _filterType = v ? TransactionType.transfer : null);
                        _fetch();
                      },
                    );
                  }),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(now.year - 3),
                        lastDate: DateTime(now.year + 3),
                        initialDateRange: _range,
                      );
                      if (picked != null) {
                        setState(() => _range = picked);
                        _fetch();
                      }
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(_range == null
                        ? 'Pilih Rentang Tanggal'
                        : '${_range!.start.toLocal().toString().split(' ').first} - ${_range!.end.toLocal().toString().split(' ').first}'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: _items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Belum ada transaksi',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Mulai tambah transaksi pertama Anda',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final tx = _items[index];
                            final isIncome = tx.type == TransactionType.income;
                            final isTransfer = tx.type == TransactionType.transfer;
                            final color = isTransfer
                                ? Colors.blue
                                : isIncome
                                    ? Colors.green
                                    : Colors.red;
                            final icon = isTransfer ? Icons.swap_horiz : (isIncome ? Icons.trending_up : Icons.trending_down);
                            final sign = isIncome ? '+ ' : isTransfer ? '' : '- ';
                            final amountText = sign + CurrencyFormatter.formatNumber(tx.amount);
                            final dateText = tx.date.toLocal().toString().split(' ').first;
                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.12),
                                  child: Icon(icon, color: color),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        amountText.replaceFirst('Rp', 'Rp '),
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        isTransfer ? 'Transfer' : (isIncome ? 'Pemasukan' : 'Pengeluaran'),
                                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: Theme.of(context).hintColor),
                                      const SizedBox(width: 4),
                                      Text(dateText, style: TextStyle(color: Theme.of(context).hintColor)),
                                      if ((tx.note ?? '').isNotEmpty) ...[
                                        const SizedBox(width: 12),
                                        Icon(Icons.notes_rounded, size: 14, color: Theme.of(context).hintColor),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            tx.note!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Theme.of(context).hintColor),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'delete') {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Hapus Transaksi'),
                                          content: const Text('Yakin ingin menghapus transaksi ini?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
                                          ],
                                        ),
                                      );
                                      if (ok == true) {
                                        await _delete(tx);
                                      }
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Summary widget removed per design change


