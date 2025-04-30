import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/conductor_model.dart';
import 'package:delivery_app/models/envio_model.dart';
import 'package:delivery_app/routes/app_routes.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:provider/provider.dart';

class ConductorDetailScreen extends StatefulWidget {
  const ConductorDetailScreen({super.key});

  @override
  State<ConductorDetailScreen> createState() => _ConductorDetailScreenState();
}

class _ConductorDetailScreenState extends State<ConductorDetailScreen> {
  late Conductor _conductor;
  late Future<List<Envio>> _enviosFuture;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _conductor = ModalRoute.of(context)!.settings.arguments as Conductor;
    _loadEnvios();
  }

  void _loadEnvios() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _enviosFuture = apiService.getDeliveryHistoryByConductor(_conductor.id!);
  }

  Future<void> _deleteConductor() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.deleteConductor(_conductor.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver deleted successfully'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting driver: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleAvailability() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final updatedConductor = _conductor.copyWith(
        disponible: !_conductor.disponible,
      );
      
      final result = await apiService.updateConductor(updatedConductor);
      
      setState(() {
        _conductor = result;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _conductor.disponible
                  ? 'Driver is now available'
                  : 'Driver is now unavailable',
            ),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating driver: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed(
                AppRoutes.conductorForm,
                arguments: _conductor,
              );
              if (result == true && mounted) {
                // Refresh driver data
                final apiService = Provider.of<ApiService>(context, listen: false);
                try {
                  final updatedConductor = await apiService.getConductorById(_conductor.id!);
                  setState(() {
                    _conductor = updatedConductor;
                  });
                } catch (e) {
                  // Handle error
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Driver'),
                        content: const Text(
                          'Are you sure you want to delete this driver? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteConductor();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: _conductor.disponible
                                    ? AppTheme.secondaryColor
                                    : AppTheme.textSecondaryColor,
                                child: Text(
                                  _conductor.nombre.isNotEmpty
                                      ? _conductor.nombre[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_conductor.nombre} ${_conductor.apellido}',
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Driver ID: ${_conductor.id}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _conductor.disponible
                                            ? AppTheme.secondaryColor.withOpacity(0.1)
                                            : AppTheme.textSecondaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _conductor.disponible ? 'Available' : 'Unavailable',
                                        style: TextStyle(
                                          color: _conductor.disponible
                                              ? AppTheme.secondaryColor
                                              : AppTheme.textSecondaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Switch(
                                value: _conductor.disponible,
                                onChanged: (value) => _toggleAvailability(),
                                activeColor: AppTheme.secondaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_conductor.vehiculo != null) ...[
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              icon: Icons.directions_car_outlined,
                              title: 'Assigned Vehicle',
                              value: '${_conductor.vehiculo!.marca} ${_conductor.vehiculo!.modelo}',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              icon: Icons.credit_card_outlined,
                              title: 'License Plate',
                              value: _conductor.vehiculo!.matricula,
                            ),
                          ],
                          if (_conductor.latitud != null && _conductor.longitud != null) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              icon: Icons.location_on_outlined,
                              title: 'Last Known Location',
                              value: 'Lat: ${_conductor.latitud!.toStringAsFixed(6)}, Lng: ${_conductor.longitud!.toStringAsFixed(6)}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Delivery history
                  Text(
                    'Delivery History',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Envio>>(
                    future: _enviosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorColor,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading delivery history',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
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
                            children: [
                              const Icon(
                                Icons.local_shipping_outlined,
                                color: AppTheme.textSecondaryColor,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No delivery history',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This driver has no deliveries yet',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      final envios = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: envios.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final envio = envios[index];
                          return Card(
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(envio.estadoEnvio).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.local_shipping_outlined,
                                  color: _getStatusColor(envio.estadoEnvio),
                                ),
                              ),
                              title: Text('Order #${envio.pedido.numeroPedido}'),
                              subtitle: Text(
                                'Status: ${envio.estadoEnvio}',
                                style: TextStyle(
                                  color: _getStatusColor(envio.estadoEnvio),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatDate(envio.fechaAsignacion),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  if (envio.fechaEntregaReal != null)
                                    Text(
                                      'Delivered: ${_formatDate(envio.fechaEntregaReal!)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.secondaryColor,
                                          ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.envioDetail,
                                  arguments: envio,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.textSecondaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':
        return AppTheme.secondaryColor;
      case 'en tránsito':
      case 'en transito':
        return AppTheme.accentColor;
      case 'pendiente':
        return AppTheme.primaryColor;
      case 'cancelado':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

