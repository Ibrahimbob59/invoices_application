import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_strings.dart';
import '../../application/providers/company_provider.dart';
import '../../application/providers/invoice_provider.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/invoice.dart';
import '../widgets/company_selector.dart';
import '../widgets/camera_scan_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  Company? _selectedCompany;
  List<String> _attachmentPaths = [];

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(invoiceFormProvider);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Selector Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.selectCompany,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.selectCompanyArabic,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CompanySelector(
                        selectedCompany: _selectedCompany,
                        onCompanySelected: (company) {
                          setState(() {
                            _selectedCompany = company;
                          });
                          ref.read(invoiceFormProvider.notifier).updateCompanyId(company?.id);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Invoice Form Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.addNewInvoice,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.addNewInvoiceArabic,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Reference Field
                      TextFormField(
                        controller: _referenceController,
                        decoration: InputDecoration(
                          labelText: '${AppStrings.reference} / ${AppStrings.referenceArabic}',
                          hintText: 'A-001, INV-2024-001',
                          prefixIcon: const Icon(Icons.numbers),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.requiredField;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          ref.read(invoiceFormProvider.notifier).updateReference(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Date Field
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: '${AppStrings.date} / ${AppStrings.dateArabic}',
                          hintText: DateFormat.yMMMd().format(DateTime.now()),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        controller: TextEditingController(
                          text: DateFormat.yMMMd().format(_selectedDate),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      
                      // Notes Field
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: '${AppStrings.notes} / ${AppStrings.notesArabic}',
                          hintText: 'Additional information...',
                          prefixIcon: const Icon(Icons.note),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          ref.read(invoiceFormProvider.notifier).updateNotes(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Attachment Section
                      const Text(
                        '${AppStrings.attachments} / ${AppStrings.attachmentsArabic}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Attachment Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.attach_file),
                              label: const Column(
                                children: [
                                  Text(AppStrings.attachFromStorage),
                                  Text(
                                    AppStrings.attachFromStorageArabic,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CameraScanButton(
                              onScanned: (text) {
                                // Add scanned text to notes
                                _notesController.text = _notesController.text + '\\n$text';
                                ref.read(invoiceFormProvider.notifier).updateNotes(_notesController.text);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Attachment List
                      if (_attachmentPaths.isNotEmpty) ...[
                        const Divider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _attachmentPaths.map((path) {
                            final fileName = path.split('/').last;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.attach_file),
                              title: Text(fileName),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () => _removeAttachment(path),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: formState.isLoading ? null : _saveInvoice,
                  icon: formState.isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Column(
                    children: [
                      Text(formState.isLoading ? 'Saving...' : AppStrings.save),
                      Text(
                        formState.isLoading ? 'جاري الحفظ...' : AppStrings.saveArabic,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      ref.read(invoiceFormProvider.notifier).updateDate(picked);
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _attachmentPaths.add(result.files.single.path!);
        });
        ref.read(invoiceFormProvider.notifier).addAttachment(result.files.single.path!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  void _removeAttachment(String path) {
    setState(() {
      _attachmentPaths.remove(path);
    });
    ref.read(invoiceFormProvider.notifier).removeAttachment(path);
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a company')),
      );
      return;
    }

    ref.read(invoiceFormProvider.notifier).setLoading(true);

    try {
      final operations = ref.read(invoiceOperationsProvider);
      
      // Check if reference is unique for this company
      final isUnique = await operations.isReferenceUniqueForCompany(
        _referenceController.text.trim(),
        _selectedCompany!.id!,
      );
      
      if (!isUnique) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.referenceExists)),
        );
        return;
      }

      // Create invoice
      final invoice = Invoice(
        companyId: _selectedCompany!.id!,
        reference: _referenceController.text.trim(),
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        attachmentPaths: _attachmentPaths,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await operations.createInvoice(invoice);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice saved successfully!')),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save invoice')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      ref.read(invoiceFormProvider.notifier).setLoading(false);
    }
  }

  void _clearForm() {
    _referenceController.clear();
    _notesController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _attachmentPaths.clear();
    });
    ref.read(invoiceFormProvider.notifier).clearForm();
  }
}