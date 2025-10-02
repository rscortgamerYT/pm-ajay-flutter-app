import 'package:flutter/material.dart';

/// Granular Role Management - Expanded role definitions with permissions
class RoleManagementPage extends StatelessWidget {
  const RoleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = [
      {
        'name': 'Block Administrator',
        'users': 3,
        'permissions': ['Full Access', 'User Management', 'Report Generation']
      },
      {
        'name': 'Project Manager',
        'users': 8,
        'permissions': ['Project Creation', 'Fund Allocation', 'Team Management']
      },
      {
        'name': 'Field Officer',
        'users': 15,
        'permissions': ['Data Entry', 'Site Visits', 'Photo Upload']
      },
      {
        'name': 'Auditor',
        'users': 5,
        'permissions': ['Audit Access', 'Compliance Review', 'Report Export']
      },
      {
        'name': 'Gram Panchayat Member',
        'users': 42,
        'permissions': ['Village Data', 'Fund Tracking', 'Citizen Reports']
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Roles: ${roles.length}', 
                    style: Theme.of(context).textTheme.titleLarge),
                  Text('Total Users: ${roles.fold(0, (sum, role) => sum + (role['users'] as int))}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...roles.map((role) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                child: Text('${role['users']}'),
              ),
              title: Text(role['name'] as String),
              subtitle: Text('${role['users']} users assigned'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Permissions:', 
                        style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      ...(role['permissions'] as List<String>).map((perm) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(perm),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit Role'),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.people, size: 16),
                            label: const Text('Manage Users'),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}