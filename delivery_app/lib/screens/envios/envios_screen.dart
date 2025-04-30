// lib/screens/envio/envios_screen.dart
import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/envio_model.dart';
import 'package:delivery_app/routes/app_routes.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EnviosScreen extends StatefulWidget {
  const EnviosScreen({super.key});

  @override
  State<EnviosScreen> createState() => _EnviosScreenState();
}

class _EnviosScreenState extends State<EnviosScreen> {
  late Future<List<Envio>> _enviosFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'In Transit', 'Delivered', 'Cancelled'];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadEnvios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadEnvios() {
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (_startDate != null && _endDate != null) {
      _enviosFuture = apiService.getDeliveryHistoryByDateRange(_startDate!, _endDate!);
    } else {
      _enviosFuture = apiService.getEnvios();
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _loadEnvios();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _loadEnvios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliveries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Filter by date',
          ),
          if (_startDate != null && _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
              tooltip: 'Clear date filter',
            ),
        ],
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
                    hintText: 'Search deliveries...',
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

                // Date filter indicator
                if (_startDate != null && _endDate != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filtered: ${DateFormat('MMM d, yyyy').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
            child: FutureBuilder<List<Envio>>(
              future: _enviosFuture,
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
                          'Error loading deliveries',
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
                              _loadEnvios();
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
                          Icons.local_shipping_outlined,
                          color: AppTheme.textSecondaryColor,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No deliveries found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _startDate != null && _endDate != null
                              ? 'No deliveries in the selected date range'
                              : 'Assign deliveries to orders to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final envios = snapshot.data!;

                // Filter by status
                var filteredEnvios = envios;
                if (_selectedFilter != 'All') {
                  filteredEnvios = envios.where((envio) {
                    final status = envio.estadoEnvio.toLowerCase();
                    final filter = _selectedFilter.toLowerCase();

                    if (filter == 'pending') {
                      return status == 'pendiente';
                    } else if (filter == 'in transit') {
                      return status == 'en tránsito' || status == 'en transito';
                    } else if (filter == 'delivered') {
                      return status == 'entregado';
                    } else if (filter == 'cancelled') {
                      return status == 'cancelado';
                    }
                    return true;
                  }).toList();
                }

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  filteredEnvios = filteredEnvios.where((envio) {
                    final query = _searchQuery.toLowerCase();
                    return envio.pedido.numeroPedido.toLowerCase().contains(query) ||
                        envio.conductor.nombre.toLowerCase().contains(query) ||
                        envio.conductor.apellido.toLowerCase().contains(query) ||
                        '${envio.conductor.nombre} ${envio.conductor.apellido}'.toLowerCase().contains(query) ||
                        envio.pedido.cliente.nombre.toLowerCase().contains(query);
                  }).toList();
                }

                if (filteredEnvios.isEmpty) {
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
                          'No matching deliveries',
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
                  itemCount: filteredEnvios.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final envio = filteredEnvios[index];
                    return _buildEnvioCard(context, envio);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvioCard(BuildContext context, Envio envio) {
    Color statusColor;
    IconData statusIcon;

    switch (envio.estadoEnvio.toLowerCase()) {
      case 'entregado':
        statusColor = AppTheme.secondaryColor;
        statusIcon = Icons.check_circle;
        break;
      case 'en tránsito':
      case 'en transito':
        statusColor = AppTheme.accentColor;
        statusIcon = Icons.local_shipping;
        break;
      case 'pendiente':
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'cancelado':
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
        title: Text('Order #${envio.pedido.numeroPedido}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${envio.pedido.cliente.nombre}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    envio.estadoEnvio,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Driver: ${envio.conductor.nombre} ${envio.conductor.apellido}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Assigned:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              DateFormat('MMM d, yyyy').format(envio.fechaAsignacion),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            AppRoutes.envioDetail,
            arguments: envio,
          );
          if (result == true && mounted) {
            setState(() {
              _loadEnvios();
            });
          }
        },
      ),
    );
  }
}