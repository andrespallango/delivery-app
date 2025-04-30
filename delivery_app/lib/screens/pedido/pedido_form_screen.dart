import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/cliente_model.dart';
import 'package:delivery_app/models/pedido_model.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:delivery_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PedidoFormScreen extends StatefulWidget {
  const PedidoFormScreen({super.key});

  @override
  State<PedidoFormScreen> createState() => _PedidoFormScreenState();
}

class _PedidoFormScreenState extends State<PedidoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroPedidoController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingClientes = false;
  bool _isEditing = false;
  Pedido? _pedido;

  String _selectedEstado = 'Pending';
  final List<String> _estadoOptions = ['Pending', 'Processing', 'Completed', 'Cancelled'];

  Cliente? _selectedCliente;
  List<Cliente> _clientes = [];

  DateTime _fechaEntregaEstimada = DateTime.now().add(const Duration(days: 2));

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Pedido) {
      _pedido = args;
      _isEditing = true;
      _numeroPedidoController.text = _pedido!.numeroPedido;
      _selectedEstado = _pedido!.estado;
      _selectedCliente = _pedido!.cliente;
      _fechaEntregaEstimada = _pedido!.fechaEntregaEstimada;
    } else {
      // Generate a random order number for new orders
      _numeroPedidoController.text = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }

  @override
  void dispose() {
    _numeroPedidoController.dispose();
    super.dispose();
  }

  Future<void> _loadClientes() async {
    setState(() {
      _isLoadingClientes = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final clientes = await apiService.getClientes();
      setState(() {
        _clientes = clientes;

        // If we're not editing and we have clients, select the first one by default
        if (!_isEditing && _clientes.isNotEmpty && _selectedCliente == null) {
          _selectedCliente = _clientes.first;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clients: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingClientes = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaEntregaEstimada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (picked != null && picked != _fechaEntregaEstimada) {
      setState(() {
        _fechaEntregaEstimada = picked;
      });
    }
  }

  Future<void> _savePedido() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final pedido = Pedido(
        id: _isEditing ? _pedido!.id : null,
        numeroPedido: _numeroPedidoController.text.trim(),
        estado: _selectedEstado,
        fechaEntregaEstimada: _fechaEntregaEstimada,
        cliente: _selectedCliente!,
      );

      if (_isEditing) {
        await apiService.updatePedido(pedido);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order updated successfully'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        }
      } else {
        await apiService.createPedido(pedido);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order created successfully'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
        title: Text(_isEditing ? 'Edit Order' : 'New Order'),
      ),
      body: SafeArea(
        child: _isLoadingClientes
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order number field
                TextFormField(
                  controller: _numeroPedidoController,
                  decoration: const InputDecoration(
                    labelText: 'Order Number',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  readOnly: _isEditing, // Don't allow editing order number for existing orders
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an order number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Status dropdown
                DropdownButtonFormField<String>(
                  value: _selectedEstado,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  items: _estadoOptions.map((String estado) {
                    return DropdownMenuItem<String>(
                      value: estado,
                      child: Text(estado),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedEstado = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Estimated delivery date
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Estimated Delivery Date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(_fechaEntregaEstimada),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Client dropdown
                if (_clientes.isEmpty) ...[
                  Card(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.errorColor,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No clients available',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please add at least one client before creating an order',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/clientes/form');
                            },
                            child: const Text('Add Client'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  DropdownButtonFormField<Cliente>(
                    value: _selectedCliente,
                    decoration: const InputDecoration(
                      labelText: 'Client',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: _clientes.map((Cliente cliente) {
                      return DropdownMenuItem<Cliente>(
                        value: cliente,
                        child: Text(cliente.nombre),
                      );
                    }).toList(),
                    onChanged: (Cliente? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCliente = newValue;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a client';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 32),

                // Save button
                if (_clientes.isNotEmpty)
                  CustomButton(
                    text: _isEditing ? 'Update Order' : 'Create Order',
                    isLoading: _isLoading,
                    onPressed: _savePedido,
                  ),
                const SizedBox(height: 16),

                // Cancel button
                if (!_isLoading)
                  CustomButton(
                    text: 'Cancel',
                    isOutlined: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}