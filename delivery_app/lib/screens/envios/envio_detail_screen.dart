import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/envio_model.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:delivery_app/services/location_service.dart';
import 'package:delivery_app/widgets/custom_button.dart';
import 'package:delivery_app/widgets/delivery_map.dart';
import 'package:delivery_app/widgets/qr_scanner_widget.dart';
import 'package:delivery_app/widgets/signature_pad.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EnvioDetailScreen extends StatefulWidget {
  const EnvioDetailScreen({super.key});

  @override
  State<EnvioDetailScreen> createState() => _EnvioDetailScreenState();
}

class _EnvioDetailScreenState extends State<EnvioDetailScreen> {
  late Envio _envio;
  bool _isLoading = false;
  bool _isUpdatingStatus = false;
  bool _showQrScanner = false;
  bool _showSignaturePad = false;
  String? _scannedQrCode;
  String? _signatureImagePath;
  final LocationService _locationService = LocationService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _envio = ModalRoute.of(context)!.settings.arguments as Envio;
  }

  Future<void> _updateDeliveryStatus(String newStatus) async {
    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final updatedEnvio = _envio.copyWith(
        estadoEnvio: newStatus,
      );

      final result = await apiService.updateEnvio(updatedEnvio);

      setState(() {
        _envio = result;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delivery status updated to $newStatus'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating delivery status: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _registerDelivery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.registerDelivery(
        _envio.id!,
        codigoQrEntrega: _scannedQrCode,
        firmaDigitalEntrega: _signatureImagePath,
      );

      setState(() {
        _envio = result;
        _showQrScanner = false;
        _showSignaturePad = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery completed successfully'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registering delivery: ${e.toString()}'),
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

  Future<void> _updateLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final result = await apiService.updateDeliveryLocation(
          _envio.id!,
          position.latitude,
          position.longitude,
        );

        setState(() {
          _envio = result;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location updated successfully'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not get current location'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating location: ${e.toString()}'),
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

  void _onQrScanned(String qrData) {
    setState(() {
      _scannedQrCode = qrData;
      _showQrScanner = false;

      // If we already have a signature, complete the delivery
      if (_signatureImagePath != null) {
        _registerDelivery();
      } else {
        // Otherwise, show signature pad
        _showSignaturePad = true;
      }
    });
  }

  void _onSignatureCapture(String signaturePath) {
    setState(() {
      _signatureImagePath = signaturePath;
      _showSignaturePad = false;

      // If we already have a QR code, complete the delivery
      if (_scannedQrCode != null) {
        _registerDelivery();
      } else {
        // Otherwise, show QR scanner
        _showQrScanner = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (_envio.estadoEnvio.toLowerCase()) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showQrScanner
          ? QrScannerWidget(onScan: _onQrScanned)
          : _showSignaturePad
          ? SignaturePad(onCapture: _onSignatureCapture)
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                                'Delivery #${_envio.id}',
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
                                  _envio.estadoEnvio,
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
                      icon: Icons.shopping_bag_outlined,
                      title: 'Order',
                      value: 'Order #${_envio.pedido.numeroPedido}',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.person_outline,
                      title: 'Client',
                      value: _envio.pedido.cliente.nombre,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.phone_outlined,
                      title: 'Client Phone',
                      value: _envio.pedido.cliente.telefono,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'Delivery Address',
                      value: _envio.pedido.cliente.direccion,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today_outlined,
                      title: 'Assignment Date',
                      value: DateFormat('MMM d, yyyy - h:mm a').format(_envio.fechaAsignacion),
                    ),
                    if (_envio.fechaEntregaReal != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        icon: Icons.check_circle_outline,
                        title: 'Delivery Date',
                        value: DateFormat('MMM d, yyyy - h:mm a').format(_envio.fechaEntregaReal!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Driver info
            Text(
              'Driver Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
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
                          backgroundColor: _envio.conductor.disponible
                              ? AppTheme.secondaryColor
                              : AppTheme.textSecondaryColor,
                          child: Text(
                            _envio.conductor.nombre.isNotEmpty
                                ? _envio.conductor.nombre[0].toUpperCase()
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
                                '${_envio.conductor.nombre} ${_envio.conductor.apellido}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _envio.conductor.disponible
                                      ? AppTheme.secondaryColor.withOpacity(0.1)
                                      : AppTheme.textSecondaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _envio.conductor.disponible ? 'Available' : 'Unavailable',
                                  style: TextStyle(
                                    color: _envio.conductor.disponible
                                        ? AppTheme.secondaryColor
                                        : AppTheme.textSecondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_envio.conductor.vehiculo != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        icon: Icons.directions_car_outlined,
                        title: 'Vehicle',
                        value: '${_envio.conductor.vehiculo!.marca} ${_envio.conductor.vehiculo!.modelo}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        icon: Icons.credit_card_outlined,
                        title: 'License Plate',
                        value: _envio.conductor.vehiculo!.matricula,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location tracking
            Text(
              'Location Tracking',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_envio.latitud != null && _envio.longitud != null) ...[
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: DeliveryMap(
                          deliveryLatitude: _envio.latitud!,
                          deliveryLongitude: _envio.longitud!,
                          clientAddress: _envio.pedido.cliente.direccion,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        icon: Icons.location_on_outlined,
                        title: 'Current Location',
                        value: 'Lat: ${_envio.latitud!.toStringAsFixed(6)}, Lng: ${_envio.longitud!.toStringAsFixed(6)}',
                      ),
                    ] else ...[
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 48,
                              color: AppTheme.textSecondaryColor,
                            ),
                            SizedBox(height: 16),
                            Text('No location data available'),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_envio.estadoEnvio.toLowerCase() == 'en tránsito' ||
                        _envio.estadoEnvio.toLowerCase() == 'en transito' ||
                        _envio.estadoEnvio.toLowerCase() == 'pendiente')
                      CustomButton(
                        text: 'Update Location',
                        icon: Icons.my_location,
                        isLoading: _isLoading,
                        onPressed: _updateLocation,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Delivery confirmation
            if (_envio.estadoEnvio.toLowerCase() != 'entregado' &&
                _envio.estadoEnvio.toLowerCase() != 'cancelado') ...[
              Text(
                'Delivery Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_envio.estadoEnvio.toLowerCase() == 'pendiente') ...[
                        CustomButton(
                          text: 'Start Delivery',
                          icon: Icons.play_arrow,
                          isLoading: _isUpdatingStatus,
                          onPressed: () => _updateDeliveryStatus('En Tránsito'),
                        ),
                      ] else if (_envio.estadoEnvio.toLowerCase() == 'en tránsito' ||
                          _envio.estadoEnvio.toLowerCase() == 'en transito') ...[
                        CustomButton(
                          text: 'Complete Delivery',
                          icon: Icons.check_circle,
                          isLoading: _isLoading,
                          onPressed: () {
                            setState(() {
                              _showQrScanner = true;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Cancel Delivery',
                          icon: Icons.cancel,
                          isOutlined: true,
                          isLoading: _isUpdatingStatus,
                          onPressed: () => _updateDeliveryStatus('Cancelado'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Delivery confirmation details
            if (_envio.estadoEnvio.toLowerCase() == 'entregado') ...[
              const SizedBox(height: 24),
              Text(
                'Delivery Confirmation',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.qr_code,
                        title: 'QR Code',
                        value: _envio.codigoQrEntrega ?? 'Not available',
                      ),
                      const SizedBox(height: 16),
                      if (_envio.firmaDigitalEntrega != null) ...[
                        Text(
                          'Digital Signature',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.textSecondaryColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            _envio.firmaDigitalEntrega!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text('Signature not available'),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        _buildInfoRow(
                          context,
                          icon: Icons.draw,
                          title: 'Digital Signature',
                          value: 'Not available',
                        ),
                      ],
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
}