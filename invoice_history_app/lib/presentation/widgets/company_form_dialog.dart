import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../application/providers/company_provider.dart';
import '../../domain/entities/company.dart';

class CompanyFormDialog extends ConsumerStatefulWidget {
  final Company? company;
  final Function(Company) onSaved;

  const CompanyFormDialog({
    super.key,
    this.company,
    required this.onSaved,
  });

  @override
  ConsumerState<CompanyFormDialog> createState() => _CompanyFormDialogState();
}

class _CompanyFormDialogState extends ConsumerState<CompanyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameController.text = widget.company!.name;
      _phoneController.text = widget.company!.phone ?? '';
      _emailController.text = widget.company!.email ?? '';
      _addressController.text = widget.company!.address ?? '';
      _taxIdController.text = widget.company!.taxId ?? '';
      _notesController.text = widget.company!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.company == null 
          ? AppStrings.insertNewCompany 
          : 'Edit Company'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.companyName} / ${AppStrings.companyNameArabic} *',
                    prefixIcon: const Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.requiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.phone} / ${AppStrings.phoneArabic}',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.email} / ${AppStrings.emailArabic}',
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.address} / ${AppStrings.addressArabic}',
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _taxIdController,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.taxId} / ${AppStrings.taxIdArabic}',
                    prefixIcon: const Icon(Icons.receipt_long),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.notes} / ${AppStrings.notesArabic}',
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCompany,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.company == null ? AppStrings.save : 'Update'),
        ),
      ],
    );
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final operations = ref.read(companyOperationsProvider);
      
      // Check if name is unique (exclude current company if editing)
      final isUnique = await operations.isNameUnique(
        _nameController.text.trim(),
        excludeId: widget.company?.id,
      );
      
      if (!isUnique) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.companyNameExists)),
        );
        return;
      }

      final company = Company(
        id: widget.company?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        taxId: _taxIdController.text.trim().isEmpty ? null : _taxIdController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.company?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.company == null) {
        success = await operations.createCompany(company);
      } else {
        success = await operations.updateCompany(company);
      }

      if (success) {
        widget.onSaved(company);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.company == null 
                ? 'Company created successfully!' 
                : 'Company updated successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.company == null 
                ? 'Failed to create company' 
                : 'Failed to update company'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}