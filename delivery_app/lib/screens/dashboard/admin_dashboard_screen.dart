import 'package:flutter/material.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:delivery_app/routes/app_routes.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
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
                            'Welcome, Admin',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your logistics operations',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats section
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  title: 'Active Orders',
                  value: '24',
                  icon: Icons.shopping_bag_outlined,
                  color: AppTheme.primaryColor,
                ),
                _buildStatCard(
                  context,
                  title: 'Deliveries Today',
                  value: '12',
                  icon: Icons.local_shipping_outlined,
                  color: AppTheme.secondaryColor,
                ),
                _buildStatCard(
                  context,
                  title: 'Available Drivers',
                  value: '8',
                  icon: Icons.person_outlined,
                  color: AppTheme.accentColor,
                ),
                _buildStatCard(
                  context,
                  title: 'Total Clients',
                  value: '156',
                  icon: Icons.people_outlined,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Management section
            Text(
              'Management',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              context,
              title: 'Clients',
              description: 'Manage client information',
              icon: Icons.people_outlined,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.clientes),
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              title: 'Drivers',
              description: 'Manage driver information',
              icon: Icons.person_outlined,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.conductores),
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              title: 'Vehicles',
              description: 'Manage vehicle information',
              icon: Icons.directions_car_outlined,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.vehiculos),
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              title: 'Orders',
              description: 'Manage orders and deliveries',
              icon: Icons.shopping_bag_outlined,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.pedidos),
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              title: 'Deliveries',
              description: 'Track and manage deliveries',
              icon: Icons.local_shipping_outlined,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.envios),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

