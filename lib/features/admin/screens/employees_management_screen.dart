import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/employee_model.dart';
import '../../billing/providers/billing_provider.dart';
import '../../../core/services/api_service.dart';

import 'package:flutter_animate/flutter_animate.dart';

class EmployeesManagementScreen extends ConsumerWidget {
  const EmployeesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees Management'),
        backgroundColor: AppColors.roseGoldPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEmployeeDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
        backgroundColor: AppColors.roseGoldPrimary,
      ),
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outlined, size: 64, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text('No employees yet', style: AppTypography.h5),
                ],
              ).animate().fade().scale(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(UIConstants.paddingM),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: UIConstants.paddingM),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accentGold.withOpacity(0.2),
                    child: Text(
                      employee.name.substring(0, 1).toUpperCase(),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(employee.name, style: AppTypography.bodyLarge),
                  subtitle: Text(employee.specialty ?? 'No Specialty'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditEmployeeDialog(context, ref, employee);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, employee);
                      }
                    },
                  ),
                ),
              ).animate().fade(duration: 400.ms, delay: (50 * index).ms).slideX(begin: 0.2, end: 0);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading employees')),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final specialtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Employee Name *',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: specialtyController,
              decoration: const InputDecoration(
                labelText: 'Specialty/Role *',
                prefixIcon: Icon(Icons.work),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  specialtyController.text.isNotEmpty) {
                Navigator.pop(context);
                
                try {
                  final api = ref.read(apiServiceProvider);
                  await api.post('/employees', {
                    'name': nameController.text,
                    'specialty': specialtyController.text,
                  });
                  
                  ref.invalidate(employeesProvider);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Employee added successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, WidgetRef ref, Employee employee) {
    final nameController = TextEditingController(text: employee.name);
    final specialtyController = TextEditingController(text: employee.specialty);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Employee Name *',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: specialtyController,
              decoration: const InputDecoration(
                labelText: 'Specialty/Role *',
                prefixIcon: Icon(Icons.work),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final api = ref.read(apiServiceProvider);
                await api.put('/employees/${employee.id}', {
                  'name': nameController.text,
                  'specialty': specialtyController.text,
                });
                
                ref.invalidate(employeesProvider);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employee updated successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee?'),
        content: Text('Are you sure you want to delete "${employee.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final api = ref.read(apiServiceProvider);
                await api.delete('/employees/${employee.id}');
                
                ref.invalidate(employeesProvider);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employee deleted'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
