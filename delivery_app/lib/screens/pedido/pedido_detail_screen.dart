import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/envio_model.dart';
import 'package:delivery_app/models/pedido_model.dart';
import 'package:delivery_app/routes/app_routes.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:delivery_app/models/conductor_model.dart';

class PedidoDetailScreen extends StatefulWidget {
  const PedidoDetailScreen({super.key});

  @override
  State<PedidoDetailScreen> createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends State<PedidoDetailScreen> {
  late Pedido _pedido;
  bool _isLoading = false;
  bool _isAssigningDelivery = false;
  Envio? _envio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pedido = ModalRoute.of(context)!.settings.arguments as Pedido;
    _checkExistingDelivery();
  }

  Future<void> _checkExistingDelivery() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final envios = await apiService.getEnvios();

      // Find if this order has an associated delivery
      final matchingEnvio = envios.firstWhere(
            (envio) => envio.pedido.id == _pedido.id,
        orElse: () => Envio(
          estadoEnvio: '',
          fechaAsignacion: DateTime.now(),
          pedido: _pedido,
          conductor: Conductor(
            nombre: '',
            apellido: '',
          ),
        ),
      );

      if (matchingEnvio.id != null) {
        setState(() {
          _envio = matchingEnvio;
        });
      }
    } catch (e) {
      // Handle error or just ignore if no delivery is found
    }
  }

  Future<void> _deletePedido() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.deletePedido(_pedido.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order deleted successfully'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting order: ${e.toString()}'),
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

  Future<void> _assignDelivery() async {
    setState(() {
      _isAssigningDelivery = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final envio = await apiService.assignEnvioToPedido(_pedido.id!);

      setState(() {
        _envio = envio;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery assigned successfully'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning delivery: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigningDelivery = false;
        });
      }
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final updatedPedido = _pedido.copyWith(
        estado: newStatus,
      );

      final result = await apiService.updatePedido(updatedPedido);

      setState(() {
        _pedido = result;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order status: ${e.toString()}'),
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
    Color statusColor;
    IconData statusIcon;

    switch (_pedido.estado.toLowerCase()) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed(
                AppRoutes.pedidoForm,
                arguments: _pedido,
              );
              if (result == true && mounted) {
                // Refresh order data
                final apiService = Provider.of<ApiService>(context, listen: false);
                try {
                  final updatedPedido = await apiService.getPedidoById(_pedido.id!);
                  setState(() {
                    _pedido = updatedPedido;
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
                  title: const Text('Delete Order'),
                  content: const Text(
                    'Are you sure you want to delete this order? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deletePedido();
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
            // Order info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            statusIcon,
                            color: statusColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${_pedido.numeroPedido}',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _pedido.estado,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                      icon: Icons.person_outline,
                      title: 'Client',
                      value: _pedido.cliente.nombre,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today_outlined,
                      title: 'Estimated Delivery Date',
                      value: '${_pedido.fechaEntregaEstimada.day}/${_pedido.fechaEntregaEstimada.month}/${_pedido.fechaEntregaEstimada.year}',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'Delivery Address',
                      value: _pedido.cliente.direccion,
                    ),
                    const SizedBox(height: 24),

                    // Status update buttons
                    if (_pedido.estado.toLowerCase() != 'completed' &&
                        _pedido.estado.toLowerCase() != 'cancelled')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Update Status',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (_pedido.estado.toLowerCase() != 'processing')
                                ElevatedButton(
                                  onPressed: () => _updateOrderStatus('Processing'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentColor,
                                  ),
                                  child: const Text('Mark as Processing'),
                                ),
                              ElevatedButton(
                                onPressed: () => _updateOrderStatus('Completed'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                                child: const Text('Mark as Completed'),
                              ),
                              OutlinedButton(
                                onPressed: () => _updateOrderStatus('Cancelled'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.errorColor,
                                ),
                                child: const Text('Cancel Order'),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Delivery section
            Text(
              'Delivery Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            if (_envio != null) ...[
              // Delivery info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getDeliveryStatusColor(_envio!.estadoEnvio).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_shipping_outlined,
                              color: _getDeliveryStatusColor(_envio!.estadoEnvio),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery #${_envio!.id}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getDeliveryStatusColor(_envio!.estadoEnvio).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _envio!.estadoEnvio,
                                    style: TextStyle(
                                      color: _getDeliveryStatusColor(_envio!.estadoEnvio),
                                      fontWeight: FontWeight.bold,
                                    ),
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
                        icon: Icons.person_outline,
                        title: 'Driver',
                        value: '${_envio!.conductor.nombre} ${_envio!.conductor.apellido}',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: 'Assignment Date',
                        value: '${_envio!.fechaAsignacion.day}/${_envio!.fechaAsignacion.month}/${_envio!.fechaAsignacion.year}',
                      ),
                      if (_envio!.fechaEntregaReal != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          icon: Icons.check_circle_outline,
                          title: 'Delivery Date',
                          value: '${_envio!.fechaEntregaReal!.day}/${_envio!.fechaEntregaReal!.month}/${_envio!.fechaEntregaReal!.year}',
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.envioDetail,
                            arguments: _envio,
                          );
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Delivery Details'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // No delivery assigned yet
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        color: AppTheme.textSecondaryColor,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No delivery assigned yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Assign a delivery to this order to start the delivery process',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isAssigningDelivery || _pedido.estado.toLowerCase() == 'cancelled'
                            ? null
                            : _assignDelivery,
                        icon: _isAssigningDelivery
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(Icons.add),
                        label: Text(_isAssigningDelivery ? 'Assigning...' : 'Assign Delivery'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  Color _getDeliveryStatusColor(String status) {
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
}

