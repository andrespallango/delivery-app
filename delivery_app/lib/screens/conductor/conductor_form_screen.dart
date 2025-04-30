import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/models/conductor_model.dart';
import 'package:delivery_app/models/vehiculo_model.dart';
import 'package:delivery_app/services/api_service.dart';
import 'package:delivery_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class ConductorFormScreen extends StatefulWidget {
  const ConductorFormScreen({super.key});

  @override
  State<ConductorFormScreen> createState() => _ConductorFormScreenState();
}

class _ConductorFormScreenState extends State<ConductorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingVehiculos = false;
  bool _isEditing = false;
  bool _disponible = true;
  Conductor? _conductor;
  Vehiculo? _selectedVehiculo;
  List<Vehiculo> _vehiculos = [];

  @override
  void initState() {
    super.initState();
    _loadVehiculos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Conductor) {
      _conductor = args;
      _isEditing = true;
      _nombreController.text = _conductor!.nombre;
      _apellidoController.text = _conductor!.apellido;
      _disponible = _conductor!.disponible;
      _selectedVehiculo = _conductor!.vehiculo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _loadVehiculos() async {
    setState(() {
      _isLoadingVehiculos = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final vehiculos = await apiService.getVehiculos();
      setState(() {
        _vehiculos = vehiculos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading vehicles: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVehiculos = false;
        });
      }
    }
  }

  Future<void> _saveConductor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      final conductor = Conductor(
        id: _isEditing ? _conductor!.id : null,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        disponible: _disponible,
        vehiculo: _selectedVehiculo,
      );

      if (_isEditing) {
        await apiService.updateConductor(conductor);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Driver updated successfully'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        }
      } else {
        await apiService.createConductor(conductor);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Driver created successfully'),
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
        title: Text(_isEditing ? 'Edit Driver' : 'New Driver'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // First name field
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last name field
                TextFormField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Availability switch
                SwitchListTile(
                  title: const Text('Available for Deliveries'),
                  value: _disponible,
                  onChanged: (value) {
                    setState(() {
                      _disponible = value;
                    });
                  },
                  activeColor: AppTheme.secondaryColor,
                ),
                const SizedBox(height: 16),

                // Vehicle dropdown
                _isLoadingVehiculos
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<Vehiculo?>(
                        value: _selectedVehiculo,
                        decoration: const InputDecoration(
                          labelText: 'Assign Vehicle (Optional)',
                          prefixIcon: Icon(Icons.directions_car_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<Vehiculo?>(
                            value: null,
                            child: Text('No Vehicle'),
                          ),
                          ..._vehiculos.map((vehiculo) {
                            return DropdownMenuItem<Vehiculo?>(
                              value: vehiculo,
                              child: Text(
                                '${vehiculo.marca} ${vehiculo.modelo} (${vehiculo.matricula})',
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (Vehiculo? newValue) {
                          setState(() {
                            _selectedVehiculo = newValue;
                          });
                        },
                      ),
                const SizedBox(height: 32),

                // Save button
                CustomButton(
                  text: _isEditing ? 'Update Driver' : 'Create Driver',
                  isLoading: _isLoading,
                  onPressed: _saveConductor,
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

