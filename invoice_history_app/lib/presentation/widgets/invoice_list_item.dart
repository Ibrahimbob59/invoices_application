import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_strings.dart';

class InvoiceListItem extends StatelessWidget {
  final Map<String, dynamic> invoice;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InvoiceListItem({
    super.key,
    required this.invoice,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasAttachments = invoice['attachment_paths'] != null && 
                          invoice['attachment_paths'].toString().isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.receipt_long,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                invoice['reference']?.toString() ?? 'N/A',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasAttachments)
              Icon(
                Icons.attach_file,
                size: 16,
                color: Colors.grey[600],
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              invoice['company_name']?.toString() ?? 'Unknown Company',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(invoice['date']?.toString()),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (invoice['notes'] != null && invoice['notes'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _truncateText(invoice['notes'].toString(), 50),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text(AppStrings.edit),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}