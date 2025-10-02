import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/demo_data_provider.dart';

class FundsListPage extends StatefulWidget {
  const FundsListPage({super.key});

  @override
  State<FundsListPage> createState() => _FundsListPageState();
}

class _FundsListPageState extends State<FundsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search funds...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Status Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Approved'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Disbursed'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Funds List
          Expanded(child: _buildFundsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Request Funds'),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedStatus == label,
      onSelected: (selected) => setState(() => _selectedStatus = label),
    );
  }

  Widget _buildFundsList() {
    final allFunds = DemoDataProvider.getDemoFunds();
    
    // Filter funds based on search and status
    final filteredFunds = allFunds.where((fund) {
      final matchesSearch = _searchController.text.isEmpty ||
          fund.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesStatus = _selectedStatus == 'All' ||
          fund.status.name.toLowerCase() == _selectedStatus.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();

    if (filteredFunds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No funds found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFunds.length,
      itemBuilder: (context, index) {
        final fund = filteredFunds[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.push('/funds/${fund.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fund.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _buildStatusChip(fund.status.name),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${(fund.amount / 10000000).toStringAsFixed(2)} Cr',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Allocated: ₹${(fund.allocatedAmount / 10000000).toStringAsFixed(2)} Cr',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Remaining: ₹${(fund.remainingAmount / 10000000).toStringAsFixed(2)} Cr',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: fund.amount > 0 ? fund.allocatedAmount / fund.amount : 0,
                    backgroundColor: Colors.grey[200],
                    minHeight: 6,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'Approved'
        ? Colors.green
        : status == 'Disbursed'
            ? Colors.blue
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}