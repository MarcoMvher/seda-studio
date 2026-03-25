import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../providers/customer_provider.dart';
import '../providers/visit_provider.dart';
import '../providers/order_provider.dart';
import '../l10n/app_localizations.dart';
import 'visit_details_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _visitSearchController = TextEditingController();
  String _visitSearchQuery = '';
  final _orderSearchController = TextEditingController();
  String _orderSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _visitSearchController.dispose();
    _orderSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadVisits(),
      _loadOrders(),
    ]);
  }

  Future<void> _loadVisits({int? orderNumber}) async {
    final visitProvider = context.read<VisitProvider>();
    await visitProvider.loadVisits(
      customerId: widget.customer.id,
      orderNumber: orderNumber,
    );
  }

  Future<void> _loadOrders() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.loadOrdersForCustomer(widget.customer.id);
  }

  Future<void> _startVisit() async {
    final l10n = AppLocalizations.of(context)!;
    // Show dialog to select order first
    final orderProvider = context.read<OrderProvider>();

    // Check if customer has orders
    if (orderProvider.orders.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noOrdersForCustomer),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Show dialog to select order
    final selectedOrder = await showDialog<Order>(
      context: context,
      builder: (context) => CreateVisitDialog(
        orders: orderProvider.orders,
        customerName: widget.customer.name,
      ),
    );

    if (selectedOrder != null && mounted) {
      final visitProvider = context.read<VisitProvider>();
      final visit = await visitProvider.createVisit(
        widget.customer.id,
        orderId: selectedOrder.orderno,
        notes: '${l10n.visitForOrder}${selectedOrder.orderno}',
      );

      if (!mounted) return;

      if (visit != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => VisitProvider(),
              child: VisitDetailsScreen(visitId: visit.id),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(visitProvider.errorMessage ?? l10n.failedToCreate),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startVisitFromOrder(Order order) async {
    final l10n = AppLocalizations.of(context)!;
    final visitProvider = context.read<VisitProvider>();
    final visit = await visitProvider.createVisit(
      widget.customer.id,
      orderId: order.orderno,
      notes: '${l10n.visitForOrder}${order.orderno}',
    );

    if (!mounted) return;

    if (visit != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => VisitProvider(),
            child: VisitDetailsScreen(visitId: visit.id),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(visitProvider.errorMessage ?? l10n.failedToCreate),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.visits, icon: const Icon(Icons.event_note)),
            Tab(text: l10n.orders, icon: const Icon(Icons.shopping_cart)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Customer Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (widget.customer.phone != null) ...[
                  const Row(
                    children: [
                      Icon(Icons.phone, size: 16),
                      SizedBox(width: 8),
                    ],
                  ),
                  Text(widget.customer.phone!),
                  const SizedBox(height: 4),
                ],
                if (widget.customer.address != null) ...[
                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 8),
                    ],
                  ),
                  Text(widget.customer.address!),
                  const SizedBox(height: 4),
                ],
                if (widget.customer.notes != null) ...[
                  const Row(
                    children: [
                      Icon(Icons.note, size: 16),
                      SizedBox(width: 8),
                    ],
                  ),
                  Text(widget.customer.notes!),
                ],
              ],
            ),
          ),

          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVisitsTab(),
                _buildOrdersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startVisit,
        icon: const Icon(Icons.add),
        label: Text(l10n.startVisit),
      ),
    );
  }

  Widget _buildVisitsTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Search field for order number
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _visitSearchController,
            decoration: InputDecoration(
              hintText: 'البحث برقم الأمر',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _visitSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _visitSearchController.clear();
                        setState(() {
                          _visitSearchQuery = '';
                        });
                        _loadVisits();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _visitSearchQuery = value;
              });
            },
            onSubmitted: (_) {
              final orderNumber = int.tryParse(_visitSearchQuery);
              _loadVisits(orderNumber: orderNumber);
            },
          ),
        ),
        // Visits list
        Expanded(
          child: Consumer<VisitProvider>(
            builder: (context, visitProvider, _) {
              if (visitProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (visitProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(visitProvider.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadVisits(
                          orderNumber: _visitSearchQuery.isNotEmpty
                              ? int.tryParse(_visitSearchQuery)
                              : null,
                        ),
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                );
              }

              if (visitProvider.visits.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _visitSearchQuery.isNotEmpty
                            ? 'لا توجد زيارات لهذا الأمر'
                            : l10n.noVisitsYet,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      if (_visitSearchQuery.isEmpty)
                        Text(
                          l10n.tapStartVisit,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _loadVisits(
                  orderNumber: _visitSearchQuery.isNotEmpty
                      ? int.tryParse(_visitSearchQuery)
                      : null,
                ),
                child: ListView.builder(
                  itemCount: visitProvider.visits.length,
                  itemBuilder: (context, index) {
                    final visit = visitProvider.visits[index];
                    return _VisitListTile(
                      visit: visit,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (_) => VisitProvider(),
                              child: VisitDetailsScreen(visitId: visit.id),
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
    );
  }

  Widget _buildOrdersTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Search field for order number
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _orderSearchController,
            decoration: InputDecoration(
              hintText: 'البحث برقم الأمر',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _orderSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _orderSearchController.clear();
                        setState(() {
                          _orderSearchQuery = '';
                        });
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _orderSearchQuery = value;
              });
            },
          ),
        ),
        // Orders list
        Expanded(
          child: Consumer<OrderProvider>(
            builder: (context, orderProvider, _) {
              print('DEBUG _buildOrdersTab: isLoading=${orderProvider.isLoading}, error=${orderProvider.errorMessage}, orders=${orderProvider.orders.length}');

              // Filter orders based on search query
              final filteredOrders = _orderSearchQuery.isNotEmpty
                  ? orderProvider.orders.where((order) =>
                      order.orderno.toString().contains(_orderSearchQuery)).toList()
                  : orderProvider.orders;

              if (orderProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (orderProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(orderProvider.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                );
              }

              if (filteredOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _orderSearchQuery.isNotEmpty
                            ? 'لا توجد أوامر بهذا الرقم'
                            : l10n.noOrdersFound,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _OrderListTile(
                      order: order,
                      onCreateVisit: () => _startVisitFromOrder(order),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VisitListTile extends StatelessWidget {
  final visit;
  final VoidCallback onTap;

  const _VisitListTile({
    required this.visit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Color getStatusColor(String status) {
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'in_progress':
          return Colors.blue;
        case 'completed':
          return Colors.green;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String getStatusDisplay(String status) {
      switch (status) {
        case 'pending':
          return l10n.statusPending;
        case 'in_progress':
          return l10n.statusInProgress;
        case 'completed':
          return l10n.statusCompleted;
        case 'cancelled':
          return l10n.statusCancelled;
        default:
          return status;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getStatusColor(visit.status).withOpacity(0.2),
          child: Icon(
            Icons.event,
            color: getStatusColor(visit.status),
          ),
        ),
        title: Text('${l10n.visit} #${visit.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.status}: ${getStatusDisplay(visit.status)}'),
            if (visit.orderNumber != null)
              Text('أمر #$visit.orderNumber'),
            if (visit.scheduledAt != null)
              Text('${l10n.scheduled}: ${visit.scheduledAt}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final Order order;
  final VoidCallback onCreateVisit;

  const _OrderListTile({
    required this.order,
    required this.onCreateVisit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.2),
          child: const Icon(
            Icons.shopping_cart,
            color: Colors.blue,
          ),
        ),
        title: Text('${l10n.order} #${order.orderno}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.date != null)
              Text('${l10n.date}: ${order.date!.year}-${order.date!.month.toString().padLeft(2, '0')}-${order.date!.day.toString().padLeft(2, '0')}'),
            if (order.itemsCount > 0)
              Text('${l10n.items}: ${order.itemsCount}'),
            Text('${l10n.status}: ${order.statusDisplay}'),
          ],
        ),
        trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: onCreateVisit,
                    tooltip: l10n.createVisitFromOrder,
                  ),
                ],
              ),
        onTap: onCreateVisit,
      ),
    );
  }
}

class CreateVisitDialog extends StatefulWidget {
  final List<Order> orders;
  final String customerName;

  const CreateVisitDialog({
    super.key,
    required this.orders,
    required this.customerName,
  });

  @override
  State<CreateVisitDialog> createState() => _CreateVisitDialogState();
}

class _CreateVisitDialogState extends State<CreateVisitDialog> {
  Order? _selectedOrder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // All orders are now available for multiple visits
    final availableOrders = widget.orders;

    // Check if there are any available orders
    if (availableOrders.isEmpty) {
      return AlertDialog(
        title: Text(l10n.createVisit),
        content: Text(l10n.noAvailableOrders),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(l10n.createVisit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.customer}: ${widget.customerName}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectOrder,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...availableOrders.map((order) {
              return RadioListTile<Order>(
                title: Text('${l10n.order} #${order.orderno}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.date != null)
                      Text('${l10n.date}: ${order.date!.year}-${order.date!.month.toString().padLeft(2, '0')}-${order.date!.day.toString().padLeft(2, '0')}'),
                    if (order.itemsCount > 0)
                      Text('${l10n.items}: ${order.itemsCount}'),
                  ],
                ),
                value: order,
                groupValue: _selectedOrder,
                onChanged: (Order? value) {
                  setState(() {
                    _selectedOrder = value;
                  });
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _selectedOrder != null
              ? () => Navigator.of(context).pop(_selectedOrder)
              : null,
          child: Text(l10n.createVisit),
        ),
      ],
    );
  }
}
