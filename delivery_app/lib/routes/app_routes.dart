import 'package:flutter/material.dart';
import 'package:delivery_app/screens/auth/login_screen.dart';
import 'package:delivery_app/screens/auth/register_screen.dart';
import 'package:delivery_app/screens/cliente/cliente_detail_screen.dart';
import 'package:delivery_app/screens/cliente/cliente_form_screen.dart';
import 'package:delivery_app/screens/cliente/clientes_screen.dart';
import 'package:delivery_app/screens/conductor/conductor_detail_screen.dart';
import 'package:delivery_app/screens/conductor/conductor_form_screen.dart';
import 'package:delivery_app/screens/conductor/conductores_screen.dart';
import 'package:delivery_app/screens/dashboard/admin_dashboard_screen.dart';
import 'package:delivery_app/screens/dashboard/driver_dashboard_screen.dart';
import 'package:delivery_app/screens/envios/envio_detail_screen.dart';
import 'package:delivery_app/screens/envios/envios_screen.dart';
import 'package:delivery_app/screens/pedido/pedido_detail_screen.dart';
import 'package:delivery_app/screens/pedido/pedido_form_screen.dart';
import 'package:delivery_app/screens/pedido/pedidos_screen.dart';
import 'package:delivery_app/screens/splash_screen.dart';
import 'package:delivery_app/screens/vehiculo/vehiculo_detail_screen.dart';
import 'package:delivery_app/screens/vehiculo/vehiculo_form_screen.dart';
import 'package:delivery_app/screens/vehiculo/vehiculos_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  static const String adminDashboard = '/admin/dashboard';
  static const String driverDashboard = '/driver/dashboard';
  
  static const String clientes = '/clientes';
  static const String clienteDetail = '/clientes/detail';
  static const String clienteForm = '/clientes/form';
  
  static const String conductores = '/conductores';
  static const String conductorDetail = '/conductores/detail';
  static const String conductorForm = '/conductores/form';
  
  static const String vehiculos = '/vehiculos';
  static const String vehiculoDetail = '/vehiculos/detail';
  static const String vehiculoForm = '/vehiculos/form';
  
  static const String pedidos = '/pedidos';
  static const String pedidoDetail = '/pedidos/detail';
  static const String pedidoForm = '/pedidos/form';
  
  static const String envios = '/envios';
  static const String envioDetail = '/envios/detail';
  
  // Route map
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    
    adminDashboard: (context) => const AdminDashboardScreen(),
    driverDashboard: (context) => const DriverDashboardScreen(),
    
    clientes: (context) => const ClientesScreen(),
    clienteDetail: (context) => const ClienteDetailScreen(),
    clienteForm: (context) => const ClienteFormScreen(),
    
    conductores: (context) => const ConductoresScreen(),
    conductorDetail: (context) => const ConductorDetailScreen(),
    conductorForm: (context) => const ConductorFormScreen(),
    
    vehiculos: (context) => const VehiculosScreen(),
    vehiculoDetail: (context) => const VehiculoDetailScreen(),
    vehiculoForm: (context) => const VehiculoFormScreen(),
    
    pedidos: (context) => const PedidosScreen(),
    pedidoDetail: (context) => const PedidoDetailScreen(),
    pedidoForm: (context) => const PedidoFormScreen(),
    
    envios: (context) => const EnviosScreen(),
    envioDetail: (context) => const EnvioDetailScreen(),
  };
}

