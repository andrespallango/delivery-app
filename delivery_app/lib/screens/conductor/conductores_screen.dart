import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/conductor_model.dart';
import 'package:delivery_app/routes/app_routes.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:provider/provider.dart';

class ConductoresScreen extends StatefulWidget {
  const ConductoresScreen({super.key});

  @override
  State<ConductoresScreen> createState() => _ConductoresScreenState();
}

class _ConductoresScreenState extends State<ConductoresScreen> {
  late Future<List<Conductor>> _conductoresFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadConductores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadConductores() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _conductoresFuture = _showOnlyAvailable
        ? apiService.getAvailableConductores()
        : apiService.getConductores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers'),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyAvailable ? Icons.check_circle : Icons.filter_list,
              color: _showOnlyAvailable ? AppTheme.secondaryColor : null,
            ),
            onPressed: () {
              setState(() {
                _showOnlyAvailable = !_showOnlyAvailable;
                _loadConductores();
              });
            },
            tooltip: 'Show only available drivers',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search drivers...',
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
            child: FutureBuilder<List<Conductor>>(
              future: _conductoresFuture,
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
                          'Error loading drivers',
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
                              _loadConductores();
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
                          Icons.person_outline,
                          color: AppTheme.textSecondaryColor,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No drivers found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showOnlyAvailable
                              ? 'No available drivers at the moment'
                              : 'Add a new driver to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final conductores = snapshot.data!;
                final filteredConductores = _searchQuery.isEmpty
                    ? conductores
                    : conductores.where((conductor) {
                        final query = _searchQuery.toLowerCase();
                        return conductor.nombre.toLowerCase().contains(query) ||
                            conductor.apellido.toLowerCase().contains(query) ||
                            '${conductor.nombre} ${conductor.apellido}'
                                .toLowerCase()
                                .contains(query);
                      }).toList();

                if (filteredConductores.isEmpty) {
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
                          'No matching drivers',
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
                  itemCount: filteredConductores.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final conductor = filteredConductores[index];
                    return _buildConductorCard(context, conductor);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed(AppRoutes.conductorForm);
          if (result == true && mounted) {
            setState(() {
              _loadConductores();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildConductorCard(BuildContext context, Conductor conductor) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: conductor.disponible
              ? AppTheme.secondaryColor
              : AppTheme.textSecondaryColor,
          child: Text(
            conductor.nombre.isNotEmpty ? conductor.nombre[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('${conductor.nombre} ${conductor.apellido}'),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: conductor.disponible
                    ? AppTheme.secondaryColor.withOpacity(0.1)
                    : AppTheme.textSecondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                conductor.disponible ? 'Available' : 'Unavailable',
                style: TextStyle(
                  color: conductor.disponible
                      ? AppTheme.secondaryColor
                      : AppTheme.textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (conductor.vehiculo != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${conductor.vehiculo!.marca} ${conductor.vehiculo!.modelo}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            AppRoutes.conductorDetail,
            arguments: conductor,
          );
          if (result == true && mounted) {
            setState(() {
              _loadConductores();
            });
          }
        },
      ),
    );
  }
}

