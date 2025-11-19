import 'package:flutter/material.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/transaction_entity.dart';
import 'edit_transaction_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedBankId;
  String? _selectedBankName;
  DateTimeRange? _selectedRange;
  final ScrollController _scrollController = ScrollController();
  int _loadedCount = 30;
  final int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        setState(() => _loadedCount += _pageSize);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomBackButton(
                    size: 40,
                    backgroundColor: const Color(0xFF2A2A2A),
                    iconColor: const Color(0xFFFFFFFF),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 18),
              _buildFilterTabs(),
              const SizedBox(height: 19),
              _buildBankDateFilters(),
              const SizedBox(height: 12),
              Expanded(child: _buildFilteredTransactionList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF949494), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFD6D6D6),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Search transactions',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF949494),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFilterTab('All', 29),
        const SizedBox(width: 31),
        _buildFilterTab('Spending', 74),
        const SizedBox(width: 31),
        _buildFilterTab('Income', 59),
        const SizedBox(width: 31),
        _buildFilterTab('Transfer', 68),
      ],
    );
  }

  Widget _buildFilterTab(String label, double underlineWidth) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: isSelected
                  ? const Color(0xFFA47FFA)
                  : const Color(0xFFD6D6D6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.366,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: underlineWidth,
            height: 1,
            color: isSelected ? const Color(0xFFA47FFA) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredTransactionList() {
    final locator = ServiceProvider.of(context);
    return StreamBuilder<List<TransactionEntity>>(
      stream: locator.transactionRepository.watchAllTransactions(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <TransactionEntity>[];
        return StreamBuilder(
          stream: locator.bankRepository.watchAllBanks(),
          builder: (context, bankSnap) {
            final banks = bankSnap.data ?? const [];
            final bankNames = {
              for (final b in banks)
                if (b.id != null) b.id!: b.name,
            };

            Iterable<TransactionEntity> filtered = items.where(
              (t) => !t.isDeleted,
            );
            if (_selectedFilter == 'Spending')
              filtered = filtered.where((t) => t.type == 'send');
            if (_selectedFilter == 'Income')
              filtered = filtered.where((t) => t.type == 'receive');
            if (_selectedFilter == 'Transfer')
              filtered = filtered.where((t) => t.type == 'transfer');
            if (_selectedBankId != null)
              filtered = filtered.where((t) => t.bankId == _selectedBankId);
            if (_selectedRange != null) {
              final start = DateTime(
                _selectedRange!.start.year,
                _selectedRange!.start.month,
                _selectedRange!.start.day,
              );
              final end = DateTime(
                _selectedRange!.end.year,
                _selectedRange!.end.month,
                _selectedRange!.end.day,
                23,
                59,
                59,
                999,
              );
              filtered = filtered.where(
                (t) => !t.date.isBefore(start) && !t.date.isAfter(end),
              );
            }
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              filtered = filtered.where((t) {
                final bankName = t.bankId != null
                    ? (bankNames[t.bankId!] ?? '')
                    : '';
                return t.name.toLowerCase().contains(q) ||
                    t.type.toLowerCase().contains(q) ||
                    bankName.toLowerCase().contains(q);
              });
            }

            final sorted = filtered.toList()
              ..sort((a, b) => b.date.compareTo(a.date));
            final paged = sorted.take(_loadedCount).toList();
            final grouped = <String, List<TransactionEntity>>{};
            for (final t in paged) {
              final key = _formatDate(t.date);
              grouped.putIfAbsent(key, () => []).add(t);
            }
            if (grouped.isEmpty) {
              return const Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF949494),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            final groups = grouped.entries.toList();
            final moreAvailable = paged.length < sorted.length;
            return ListView.builder(
              controller: _scrollController,
              itemCount: groups.length + (moreAvailable ? 1 : 0),
              itemBuilder: (context, index) {
                if (moreAvailable && index == groups.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final entry = groups[index];
                final date = entry.key;
                final txs = entry.value;
                final data = txs.map((t) {
                  final isPositive = t.type == 'receive';
                  final sign = isPositive ? '+' : '-';
                  final amountStr = '$sign\$${t.amount.toStringAsFixed(0)}';

                  String description;
                  if (t.type == 'transfer' &&
                      t.bankId != null &&
                      t.toBankId != null) {
                    final fromBank = bankNames[t.bankId!] ?? '-';
                    final toBank = bankNames[t.toBankId!] ?? '-';
                    description = '$fromBank → $toBank';
                  } else {
                    description = t.bankId != null
                        ? (bankNames[t.bankId!] ?? '-')
                        : '-';
                  }

                  return _TransactionData(
                    id: t.id!,
                    category: t.name,
                    description: description,
                    time: _formatTime(t.date),
                    amount: amountStr,
                    isPositive: isPositive,
                    icon: _iconForType(t.type),
                    bankId: t.bankId,
                    type: t.type,
                    rawAmount: t.amount,
                  );
                }).toList();
                return Column(
                  children: [
                    _buildTransactionSection(date, data),
                    if (index < groups.length - 1) const SizedBox(height: 14),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute$ampm';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'receive':
        return Icons.arrow_downward;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.arrow_upward;
    }
  }

  Widget _buildBankDateFilters() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _showBankPicker,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance,
                    color: Color(0xFFD6D6D6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedBankName ?? 'All Banks',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFD6D6D6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_selectedBankId != null)
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedBankId = null;
                        _selectedBankName = null;
                      }),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.clear,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                      ),
                    ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFFD6D6D6),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: _showDateRange,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.date_range,
                    color: Color(0xFFD6D6D6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedRange == null
                          ? 'Any time'
                          : '${_selectedRange!.start.month}/${_selectedRange!.start.day} - ${_selectedRange!.end.month}/${_selectedRange!.end.day}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFD6D6D6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_selectedRange != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedRange = null),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.clear,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                      ),
                    ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFFD6D6D6),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBankPicker() {
    final locator = ServiceProvider.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter by Bank',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFD6D6D6),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text(
                  'All Banks',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFFD6D6D6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBankId = null;
                    _selectedBankName = null;
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(color: Color(0xFF4F4F4F)),
              SizedBox(
                height: 320,
                child: StreamBuilder(
                  stream: locator.bankRepository.watchAllBanks(),
                  builder: (context, snapshot) {
                    final banks = snapshot.data ?? const [];
                    return ListView.builder(
                      itemCount: banks.length,
                      itemBuilder: (context, index) {
                        final b = banks[index];
                        return ListTile(
                          title: Text(
                            b.name,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              color: Color(0xFFD6D6D6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedBankId = b.id;
                              _selectedBankName = b.name;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFBA9BFF),
              onPrimary: Color(0xFF000000),
              surface: Color(0xFF101010),
              onSurface: Color(0xFFD6D6D6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedRange = picked);
  }

  Widget _buildTransactionSection(
    String date,
    List<_TransactionData> transactions,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD6D6D6).withOpacity(0.05),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFFC6C6C6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.366,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFC6C6C6)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.only(bottom: 15),
                    color: const Color(0xFFB5B5B5).withOpacity(0.5),
                  ),
                _buildTransactionItem(transaction),
                if (index < transactions.length - 1) const SizedBox(height: 15),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(_TransactionData transaction) {
    return GestureDetector(
      onLongPress: () => _showTransactionActions(transaction),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(transaction.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFFE6E6E6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.366,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF949494),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amount,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: transaction.isPositive
                      ? const Color(0xFFA47FFA)
                      : const Color(0xFF949494),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                transaction.time,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF9E9E9E),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToEdit(transaction),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFBA9BFF).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFFBA9BFF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _confirmDelete(transaction),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionActions(_TransactionData tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFD6D6D6)),
              title: const Text(
                'Update Transaction',
                style: TextStyle(color: Color(0xFFD6D6D6)),
              ),
              onTap: () async {
                Navigator.pop(context);
                _navigateToEdit(tx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Delete Transaction',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(context);
                _confirmDelete(tx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(_TransactionData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF191919),
        title: const Text(
          'Delete Transaction',
          style: TextStyle(color: Color(0xFFD6D6D6), fontFamily: 'Poppins'),
        ),
        content: Text(
          'Are you sure you want to delete "${data.category}" (${data.amount})?',
          style: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTransaction(data);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(_TransactionData data) async {
    const red = '\x1B[31m';
    const green = '\x1B[32m';
    const reset = '\x1B[0m';
    try {
      final locator = ServiceProvider.of(context);
      print('🟨 ${red}[DB] DELETE_TRANSACTION_REQUEST id=${data.id}${reset}');
      await locator.transactionRepository.deleteTransaction(data.id);
      print('🟩 ${green}[DB] DELETE_TRANSACTION_SUCCESS id=${data.id}${reset}');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      }
    } catch (e, st) {
      print('🟥 ${red}[DB] DELETE_TRANSACTION_ERROR id=${data.id}: $e${reset}');
      print('🟥 ${red}$st${reset}');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  Future<void> _navigateToEdit(_TransactionData data) async {
    final locator = ServiceProvider.of(context);

    // Fetch the full transaction entity
    final txEntity = await locator.transactionRepository
        .watchAllTransactions()
        .first
        .then((list) => list.firstWhere((t) => t.id == data.id));

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditTransactionPage(transaction: txEntity),
        ),
      );
    }
  }
}

class _TransactionData {
  final int id;
  final String category;
  final String description;
  final String time;
  final String amount;
  final bool isPositive;
  final IconData icon;
  final int? bankId;
  final String type;
  final double rawAmount;

  _TransactionData({
    required this.id,
    required this.category,
    required this.description,
    required this.time,
    required this.amount,
    required this.isPositive,
    required this.icon,
    required this.bankId,
    required this.type,
    required this.rawAmount,
  });
}
