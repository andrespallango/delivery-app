import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/pedido_model.dart';
import 'package:delivery_app/routes/app_routes.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:provider/provider.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late Future<List<Pedido>> _pedidosFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'Processing', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPedidos() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _pedidosFuture = apiService.getPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
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
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                          checkmarkColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondaryColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pedido>>(
              future: _pedidosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading orders',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loadPedidos();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppTheme.textSecondaryColor,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a new order to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final pedidos = snapshot.data!;
                
                // Filter by status
                var filteredPedidos = pedidos;
                if (_selectedFilter != 'All') {
                  filteredPedidos = pedidos.where((pedido) {
                    return pedido.estado.toLowerCase() == _selectedFilter.toLowerCase();
                  }).toList();
                }
                
                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  filteredPedidos = filteredPedidos.where((pedido) {
                    final query = _searchQuery.toLowerCase();
                    return pedido.numeroPedido.toLowerCase().contains(query) ||
                        pedido.cliente.nombre.toLowerCase().contains(query);
                  }).toList();
                }

                if (filteredPedidos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          color: AppTheme.textSecondaryColor,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matching orders',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term or filter',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPedidos.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final pedido = filteredPedidos[index];
                    return _buildPedidoCard(context, pedido);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed(AppRoutes.pedidoForm);
          if (result == true && mounted) {
            setState(() {
              _loadPedidos();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPedidoCard(BuildContext context, Pedido pedido) {
    Color statusColor;
    IconData statusIcon;

    switch (pedido.estado.toLowerCase()) {
      case 'pending':
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'processing':
        statusColor = AppTheme.accentColor;
        statusIcon = Icons.sync;
        break;
      case 'completed':
        statusColor = AppTheme.secondaryColor;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.textSecondaryColor;
        statusIcon = Icons.help_outline;
    }

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
          ),
        ),
        title: Text('Order #${pedido.numeroPedido}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${pedido.cliente.nombre}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pedido.estado,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Est. Delivery:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${pedido.fechaEntregaEstimada.day}/${pedido.fechaEntregaEstimada.month}/${pedido.fechaEntregaEstimada.year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            AppRoutes.pedidoDetail,
            arguments: pedido,
          );
          if (result == true && mounted) {
            setState(() {
              _loadPedidos();
            });
          }
        },
      ),
    );
  }
}

