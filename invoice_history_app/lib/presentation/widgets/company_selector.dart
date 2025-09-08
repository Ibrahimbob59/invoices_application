import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/company.dart';
import '../../application/providers/company_provider.dart';
import '../../core/constants/app_strings.dart';

class CompanySelector extends ConsumerStatefulWidget {
  final Company? selectedCompany;
  final ValueChanged<Company?> onCompanySelected;

  const CompanySelector({
    super.key,
    required this.selectedCompany,
    required this.onCompanySelected,
  });

  @override
  ConsumerState<CompanySelector> createState() => _CompanySelectorState();
}

class _CompanySelectorState extends ConsumerState<CompanySelector> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCompanies = ref.watch(filteredCompaniesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected company display / Search field
        if (widget.selectedCompany != null && !_isExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.business, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedCompany!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.selectedCompany!.phone != null)
                        Text(
                          widget.selectedCompany!.phone!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isExpanded = true;
                      _searchController.text = widget.selectedCompany!.name;
                    });
                  },
                ),
              ],
            ),
          )
        else
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: '${AppStrings.searchCompanies} / ${AppStrings.searchCompaniesArabic}',
              hintText: 'Start typing company name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.selectedCompany != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                          _searchController.clear();
                        });
                        ref.read(companySearchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              ref.read(companySearchQueryProvider.notifier).state = value;
              setState(() {
                _isExpanded = true;
              });
            },
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
            },
          ),

        // Company list
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: filteredCompanies.when(
              data: (companies) {
                if (companies.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      AppStrings.noCompaniesYet,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: companies.length,
                  itemBuilder: (context, index) {
                    final company = companies[index];
                    return ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(company.name),
                      subtitle: company.phone != null
                          ? Text(company.phone!)
                          : null,
                      onTap: () {
                        widget.onCompanySelected(company);
                        setState(() {
                          _isExpanded = false;
                        });
                        ref.read(companySearchQueryProvider.notifier).state = '';
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $error'),
              ),
            ),
          ),
      ],
    );
  }
}