import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/visit_provider.dart';
import '../providers/order_provider.dart';
import '../models/customer.dart';
import '../l10n/app_localizations.dart';
import 'customer_details_screen.dart';
import 'settings_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool _isPerformingSearch = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final customerProvider = context.read<CustomerProvider>();
    if (_isPerformingSearch) return;

    // When we're near the bottom, load more
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (customerProvider.canLoadMore) {
        _loadMoreCustomers();
      }
    }
  }

  Future<void> _loadCustomers() async {
    try {
      print('DEBUG: Starting to load customers...');
      final customerProvider = context.read<CustomerProvider>();
      print('DEBUG: Got customerProvider');
      await customerProvider.loadCustomers(search: _searchQuery);
      print('DEBUG: loadCustomers completed');
    } catch (e) {
      print('DEBUG: Error in _loadCustomers: $e');
      rethrow;
    }
  }

  Future<void> _loadMoreCustomers() async {
    try {
      print('DEBUG: Loading more customers...');
      final customerProvider = context.read<CustomerProvider>();
      await customerProvider.loadMoreCustomers();
      print('DEBUG: loadMoreCustomers completed');
    } catch (e) {
      print('DEBUG: Error in _loadMoreCustomers: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customers),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchCustomers,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _loadCustomers();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (_) async {
                _isPerformingSearch = true;
                await _loadCustomers();
                _isPerformingSearch = false;
              },
            ),
          ),
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, customerProvider, _) {
                if (customerProvider.isLoading && customerProvider.customers.isEmpty) {
                  return Center(child: Text(l10n.loadingCustomers));
                }

                if (customerProvider.errorMessage != null && customerProvider.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(customerProvider.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCustomers,
                          child: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  );
                }

                if (customerProvider.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? l10n.noCustomersFound
                              : 'لا يوجد عملاء',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await customerProvider.loadCustomers(search: _searchQuery, refresh: true);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: customerProvider.customers.length + (customerProvider.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the bottom
                      if (index == customerProvider.customers.length) {
                        return customerProvider.isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final customer = customerProvider.customers[index];
                      return _CustomerListTile(
                        customer: customer,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(create: (_) => VisitProvider()),
                                  ChangeNotifierProvider(create: (_) => OrderProvider()),
                                ],
                                child: CustomerDetailsScreen(customer: customer),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadCustomers,
        icon: const Icon(Icons.refresh),
        label: const Text('تحديث'),
      ),
    );
  }
}

class _CustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const _CustomerListTile({
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            customer.name[0].toUpperCase(),
            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(customer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone != null) ...[
              Text(customer.phone!),
            ],
            if (customer.address != null) ...[
              Text(
                customer.address!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Order information
            if (customer.hasOrders) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 14, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${customer.ordersCount} طلب',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (customer.latestOrderDate != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(customer.latestOrderDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    } else {
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    }
  }
}
