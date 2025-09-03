import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_page.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/transaction_service.dart';

class DashboardPage extends StatefulWidget {
  final UserModel? currentUser;

  const DashboardPage({super.key, this.currentUser});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final TransactionService _service = TransactionService();
  DateTimeRange? _range;
  bool _loading = false;
  double _income = 0;
  double _expense = 0;

  @override
  void initState() {
    super.initState();
    _setDefaultRange();
    _refreshTotals();
  }

  void _setDefaultRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    _range = DateTimeRange(start: startOfMonth, end: endOfMonth);
  }

  Future<void> _refreshTotals() async {
    if (_range == null) return;
    setState(() => _loading = true);
    try {
      final totals = await _service.getTotals(
        start: DateTime(_range!.start.year, _range!.start.month, _range!.start.day),
        end: DateTime(_range!.end.year, _range!.end.month, _range!.end.day, 23, 59, 59),
      );
      setState(() {
        _income = totals['income'] ?? 0;
        _expense = totals['expense'] ?? 0;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Expose refresh for parent
  Future<void> refresh() async {
    await _refreshTotals();
  }

  double get _balance => _income - _expense;

  Widget _buildBalanceCard(String title, String amount, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang, ${widget.currentUser?.fullName ?? 'User'}!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Kelola keuangan Anda dengan bijak', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      'Saldo',
                      'Rp ${_balance.toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBalanceCard(
                      'Pemasukan',
                      'Rp ${_income.toStringAsFixed(0)}',
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _buildBalanceCard(
                  'Pengeluaran',
                  'Rp ${_expense.toStringAsFixed(0)}',
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Row(
                children: [
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
                        _refreshTotals();
                      }
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter Tanggal'),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<DateFilterPreset>(
                    value: DateFilterPreset.month,
                    items: const [
                      DropdownMenuItem(value: DateFilterPreset.day, child: Text('Harian')),
                      DropdownMenuItem(value: DateFilterPreset.month, child: Text('Bulanan')),
                      DropdownMenuItem(value: DateFilterPreset.year, child: Text('Tahunan')),
                    ],
                    onChanged: (preset) {
                      if (preset == null) return;
                      final now = DateTime.now();
                      if (preset == DateFilterPreset.day) {
                        final start = DateTime(now.year, now.month, now.day);
                        final end = DateTime(now.year, now.month, now.day);
                        setState(() => _range = DateTimeRange(start: start, end: end));
                      } else if (preset == DateFilterPreset.month) {
                        final start = DateTime(now.year, now.month, 1);
                        final end = DateTime(now.year, now.month + 1, 0);
                        setState(() => _range = DateTimeRange(start: start, end: end));
                      } else {
                        final start = DateTime(now.year, 1, 1);
                        final end = DateTime(now.year, 12, 31);
                        setState(() => _range = DateTimeRange(start: start, end: end));
                      }
                      _refreshTotals();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Perbandingan', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: _income <= 0 && _expense <= 0 ? 1 : _income,
                            title: _income <= 0 && _expense <= 0 ? '0' : 'Pemasukan',
                            titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            color: Colors.green,
                            radius: 70,
                          ),
                          PieChartSectionData(
                            value: _income <= 0 && _expense <= 0 ? 1 : _expense,
                            title: _income <= 0 && _expense <= 0 ? '' : 'Pengeluaran',
                            titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            color: Colors.red,
                            radius: 70,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Aksi Cepat', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      'Tambah Pemasukan',
                      Icons.add_circle,
                      Colors.green,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Tambah Pengeluaran',
                      Icons.remove_circle,
                      Colors.red,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

enum DateFilterPreset { day, month, year }


