import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class EmployeePerformanceTable extends StatelessWidget {
  final List<dynamic> employeePerformance;

  const EmployeePerformanceTable({super.key, required this.employeePerformance});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee Performance', style: AppTypography.h6),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Services')),
                  DataColumn(label: Text('Revenue'), numeric: true),
                ],
                rows: employeePerformance.map((employee) {
                  return DataRow(
                    cells: [
                      DataCell(Text(employee['name'] ?? 'Unknown')),
                      DataCell(Text('${employee['servicesCount']}')),
                      DataCell(Text(currencyFormat.format(employee['revenue']))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
