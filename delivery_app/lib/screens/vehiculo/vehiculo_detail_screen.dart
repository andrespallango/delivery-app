import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/vehiculo_model.dart';
import 'package:delivery_app/routes/app_routes.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:provider/provider.dart';

class VehiculoDetailScreen extends StatefulWidget {
  const VehiculoDetailScreen({super.key});

  @override
  State<VehiculoDetailScreen> createState() => _VehiculoDetailScreenState();
}

class _VehiculoDetailScreenState extends State<VehiculoDetailScreen> {
  late Vehiculo _vehiculo;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vehiculo = ModalRoute.of(context)!.settings.arguments as Vehiculo;
  }

  Future<void> _deleteVehiculo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.deleteVehiculo(_vehiculo.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle deleted successfully'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting vehicle: ${e.toString()}'),
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
    IconData vehicleIcon;
    switch (_vehiculo.tipo.toLowerCase()) {
      case 'car':
      case 'carro':
      case 'automóvil':
      case 'automovil':
        vehicleIcon = Icons.directions_car;
        break;
      case 'truck':
      case 'camión':
      case 'camion':
        vehicleIcon = Icons.local_shipping;
        break;
      case 'motorcycle':
      case 'moto':
      case 'motocicleta':
        vehicleIcon = Icons.two_wheeler;
        break;
      case 'van':
      case 'furgoneta':
        vehicleIcon = Icons.airport_shuttle;
        break;
      default:
        vehicleIcon = Icons.directions_car;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed(
                AppRoutes.vehiculoForm,
                arguments: _vehiculo,
              );
              if (result == true && mounted) {
                // Refresh vehicle data
                final apiService = Provider.of<ApiService>(context, listen: false);
                try {
                  final updatedVehiculo = await apiService.getVehiculoById(_vehiculo.id!);
                  setState(() {
                    _vehiculo = updatedVehiculo;
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
                        title: const Text('Delete Vehicle'),
                        content: const Text(
                          'Are you sure you want to delete this vehicle? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteVehiculo();
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
                  // Vehicle info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  vehicleIcon,
                                  color: AppTheme.primaryColor,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_vehiculo.marca} ${_vehiculo.modelo}',
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Vehicle ID: ${_vehiculo.id}',
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
                          _buildInfoRow(
                            context,
                            icon: Icons.credit_card_outlined,
                            title: 'License Plate',
                            value: _vehiculo.matricula,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            icon: Icons.category_outlined,
                            title: 'Type',
                            value: _vehiculo.tipo,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            icon: Icons.business_outlined,
                            title: 'Brand',
                            value: _vehiculo.marca,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            icon: Icons.model_training_outlined,
                            title: 'Model',
                            value: _vehiculo.modelo,
                          ),
                        ],
                      ),
                    ),
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
}

