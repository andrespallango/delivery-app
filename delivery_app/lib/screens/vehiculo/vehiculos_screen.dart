import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/vehiculo_model.dart';
import 'package:delivery_app/routes/app_routes.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:provider/provider.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  late Future<List<Vehiculo>> _vehiculosFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVehiculos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadVehiculos() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _vehiculosFuture = apiService.getVehiculos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vehicles...',
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
          ),
          Expanded(
            child: FutureBuilder<List<Vehiculo>>(
              future: _vehiculosFuture,
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
                          'Error loading vehicles',
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
                              _loadVehiculos();
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
                          Icons.directions_car_outlined,
                          color: AppTheme.textSecondaryColor,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vehicles found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a new vehicle to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final vehiculos = snapshot.data!;
                final filteredVehiculos = _searchQuery.isEmpty
                    ? vehiculos
                    : vehiculos.where((vehiculo) {
                        final query = _searchQuery.toLowerCase();
                        return vehiculo.matricula.toLowerCase().contains(query) ||
                            vehiculo.marca.toLowerCase().contains(query) ||
                            vehiculo.modelo.toLowerCase().contains(query) ||
                            vehiculo.tipo.toLowerCase().contains(query);
                      }).toList();

                if (filteredVehiculos.isEmpty) {
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
                          'No matching vehicles',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredVehiculos.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final vehiculo = filteredVehiculos[index];
                    return _buildVehiculoCard(context, vehiculo);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed(AppRoutes.vehiculoForm);
          if (result == true && mounted) {
            setState(() {
              _loadVehiculos();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVehiculoCard(BuildContext context, Vehiculo vehiculo) {
    IconData vehicleIcon;
    switch (vehiculo.tipo.toLowerCase()) {
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

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            vehicleIcon,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
        subtitle: Text('Plate: ${vehiculo.matricula}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            AppRoutes.vehiculoDetail,
            arguments: vehiculo,
          );
          if (result == true && mounted) {
            setState(() {
              _loadVehiculos();
            });
          }
        },
      ),
    );
  }
}

