import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/cliente_model.dart';
import 'package:delivery_app/models/envio_model.dart';
import 'package:delivery_app/routes/app_routes.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:provider/provider.dart';

class ClienteDetailScreen extends StatefulWidget {
  const ClienteDetailScreen({super.key});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  late Cliente _cliente;
  late Future<List<Envio>> _enviosFuture;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cliente = ModalRoute.of(context)!.settings.arguments as Cliente;
    _loadEnvios();
  }

  void _loadEnvios() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _enviosFuture = apiService.getDeliveryHistoryByCliente(_cliente.id!);
  }

  Future<void> _deleteCliente() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.deleteCliente(_cliente.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client deleted successfully'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting client: ${e.toString()}'),
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
        title: const Text('Client Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed(
                AppRoutes.clienteForm,
                arguments: _cliente,
              );
              if (result == true && mounted) {
                // Refresh client data
                final apiService = Provider.of<ApiService>(context, listen: false);
                try {
                  final updatedCliente = await apiService.getClienteById(_cliente.id!);
                  setState(() {
                    _cliente = updatedCliente;
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
                        title: const Text('Delete Client'),
                        content: const Text(
                          'Are you sure you want to delete this client? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteCliente();
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
                  // Client info card
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
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  _cliente.nombre.isNotEmpty
                                      ? _cliente.nombre[0].toUpperCase()
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
                                      _cliente.nombre,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Client ID: ${_cliente.id}',
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
                            icon: Icons.email_outlined,
                            title: 'Email',
                            value: _cliente.email,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            icon: Icons.phone_outlined,
                            title: 'Phone',
                            value: _cliente.telefono,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            icon: Icons.location_on_outlined,
                            title: 'Address',
                            value: _cliente.direccion,
                          ),
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
                                'This client has no deliveries yet',
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

