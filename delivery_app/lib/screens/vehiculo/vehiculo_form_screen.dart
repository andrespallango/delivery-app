import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/vehiculo_model.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:delivery_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class VehiculoFormScreen extends StatefulWidget {
  const VehiculoFormScreen({super.key});

  @override
  State<VehiculoFormScreen> createState() => _VehiculoFormScreenState();
}

class _VehiculoFormScreenState extends State<VehiculoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matriculaController = TextEditingController();
  final _tipoController = TextEditingController();
  final _modeloController = TextEditingController();
  final _marcaController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  Vehiculo? _vehiculo;
  String _selectedTipo = 'Car';
  
  final List<String> _tipoOptions = ['Car', 'Truck', 'Motorcycle', 'Van'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Vehiculo) {
      _vehiculo = args;
      _isEditing = true;
      _matriculaController.text = _vehiculo!.matricula;
      _tipoController.text = _vehiculo!.tipo;
      _modeloController.text = _vehiculo!.modelo;
      _marcaController.text = _vehiculo!.marca;
      
      // Try to match the vehicle type with available options
      final matchedTipo = _tipoOptions.firstWhere(
        (tipo) => _vehiculo!.tipo.toLowerCase() == tipo.toLowerCase(),
        orElse: () => 'Car',
      );
      _selectedTipo = matchedTipo;
    }
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    _tipoController.dispose();
    _modeloController.dispose();
    _marcaController.dispose();
    super.dispose();
  }

  Future<void> _saveVehiculo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      final vehiculo = Vehiculo(
        id: _isEditing ? _vehiculo!.id : null,
        matricula: _matriculaController.text.trim(),
        tipo: _selectedTipo,
        modelo: _modeloController.text.trim(),
        marca: _marcaController.text.trim(),
      );

      if (_isEditing) {
        await apiService.updateVehiculo(vehiculo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle updated successfully'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        }
      } else {
        await apiService.createVehiculo(vehiculo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle created successfully'),
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
        title: Text(_isEditing ? 'Edit Vehicle' : 'New Vehicle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // License plate field
                TextFormField(
                  controller: _matriculaController,
                  decoration: const InputDecoration(
                    labelText: 'License Plate',
                    prefixIcon: Icon(Icons.credit_card_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a license plate';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type field (dropdown)
                DropdownButtonFormField<String>(
                  value: _selectedTipo,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _tipoOptions.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTipo = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a vehicle type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Brand field
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a brand';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Model field
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    prefixIcon: Icon(Icons.model_training_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a model';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Save button
                CustomButton(
                  text: _isEditing ? 'Update Vehicle' : 'Create Vehicle',
                  isLoading: _isLoading,
                  onPressed: _saveVehiculo,
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

