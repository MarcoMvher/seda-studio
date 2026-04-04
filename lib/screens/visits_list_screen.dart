import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visit_provider.dart';
import '../providers/auth_provider.dart';
import '../models/visit.dart';
import 'visit_details_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';
import '../widgets/error_display.dart';

class VisitsListScreen extends StatefulWidget {
  const VisitsListScreen({super.key});

  @override
  State<VisitsListScreen> createState() => _VisitsListScreenState();
}

class _VisitsListScreenState extends State<VisitsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVisits() async {
    final visitProvider = context.read<VisitProvider>();
    await visitProvider.loadVisits(status: _selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.visits),
        actions: [
          // Status filter dropdown
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filter,
            onSelected: (status) {
              setState(() {
                _selectedStatus = status;
                _loadVisits();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Text(l10n.allVisits),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'pending',
                child: Text(l10n.statusPending),
              ),
              PopupMenuItem(
                value: 'in_progress',
                child: Text(l10n.statusInProgress),
              ),
              PopupMenuItem(
                value: 'completed',
                child: Text(l10n.statusCompleted),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVisits,
            tooltip: l10n.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider, l10n),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchVisits,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Current filter indicator
          if (_selectedStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Chip(
                label: Text(_getStatusText(_selectedStatus!)),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    _selectedStatus = null;
                    _loadVisits();
                  });
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

                if (visitProvider.error != null) {
                  return ErrorDisplay(
                    error: visitProvider.error!,
                    onRetry: _loadVisits,
                  );
                }

                List<Visit> filteredVisits = visitProvider.visits;

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  filteredVisits = filteredVisits.where((visit) {
                    final searchLower = _searchQuery.toLowerCase();
                    return visit.customerName?.toLowerCase().contains(searchLower) == true ||
                        visit.id.toString().contains(searchLower) ||
                        (visit.orderNumber != null && visit.orderNumber.toString().contains(searchLower));
                  }).toList();
                }

                if (filteredVisits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedStatus == null ? Icons.event_note : Icons.filter_list,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus == null ? l10n.noVisitsYet : l10n.noVisitsWithStatus,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadVisits,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredVisits.length,
                    itemBuilder: (context, index) {
                      final visit = filteredVisits[index];
                      return _buildVisitCard(context, visit, l10n);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authProvider.user?.username ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.branchUser,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: Text(l10n.visits),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.logoutConfirm),
                  content: Text(l10n.logoutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.no),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.yes),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, Visit visit, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => VisitProvider(),
                child: VisitDetailsScreen(visitId: visit.id),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getStatusColor(visit.status).withOpacity(0.2),
                    child: Icon(
                      Icons.event,
                      color: _getStatusColor(visit.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.visit} #${visit.id}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (visit.customerName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            visit.customerName!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (visit.delegateName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.by} ${visit.delegateName}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusChip(visit.status, l10n),
                ],
              ),
              if (visit.orderNumber != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.order} #${visit.orderNumber}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  visit.notes!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, AppLocalizations l10n) {
    return Chip(
      label: Text(
        _getStatusText(status),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: _getStatusColor(status).withOpacity(0.1),
      side: BorderSide(
        color: _getStatusColor(status),
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
