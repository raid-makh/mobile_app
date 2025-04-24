import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> universities;
  final List<String> years;
  final List<String> types;
  final List<String> modules;

  final List<String> selectedUniversities;
  final List<String> selectedYears;
  final List<String> selectedTypes;
  final List<String> selectedModules;

  final Function({
    required List<String> universities,
    required List<String> years,
    required List<String> types,
    required List<String> modules,
  })
  onApplyFilters;

  final VoidCallback onClearFilters;

  const FilterBottomSheet({
    Key? key,
    required this.universities,
    required this.years,
    required this.types,
    required this.modules,
    required this.selectedUniversities,
    required this.selectedYears,
    required this.selectedTypes,
    required this.selectedModules,
    required this.onApplyFilters,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _selectedUniversities;
  late List<String> _selectedYears;
  late List<String> _selectedTypes;
  late List<String> _selectedModules;

  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _moduleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedUniversities = List.from(widget.selectedUniversities);
    _selectedYears = List.from(widget.selectedYears);
    _selectedTypes = List.from(widget.selectedTypes);
    _selectedModules = List.from(widget.selectedModules);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchableFilterSection(
                    title: 'University',
                    controller: _universityController,
                    allItems: widget.universities,
                    selectedItems: _selectedUniversities,
                    onChanged:
                        (items) =>
                            setState(() => _selectedUniversities = items),
                  ),
                  const Divider(),
                  _buildFilterSection(
                    title: 'Year',
                    items: widget.years,
                    selectedItems: _selectedYears,
                    onChanged:
                        (items) => setState(() => _selectedYears = items),
                  ),
                  const Divider(),
                  _buildFilterSection(
                    title: 'Type',
                    items: widget.types,
                    selectedItems: _selectedTypes,
                    onChanged:
                        (items) => setState(() => _selectedTypes = items),
                  ),
                  const Divider(),
                  _buildSearchableFilterSection(
                    title: 'Module',
                    controller: _moduleController,
                    allItems: widget.modules,
                    selectedItems: _selectedModules,
                    onChanged:
                        (items) => setState(() => _selectedModules = items),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filter Materials',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedUniversities.clear();
                _selectedYears.clear();
                _selectedTypes.clear();
                _selectedModules.clear();
              });
              widget.onClearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(
                universities: _selectedUniversities,
                years: _selectedYears,
                types: _selectedTypes,
                modules: _selectedModules,
              );
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items.map((item) {
                final isSelected = selectedItems.contains(item);
                return FilterChip(
                  label: Text(item),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(selectedItems);
                    selected ? updated.add(item) : updated.remove(item);
                    onChanged(updated.toSet().toList());
                  },
                  showCheckmark: true,
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSearchableFilterSection({
    required String title,
    required TextEditingController controller,
    required List<String> allItems,
    required List<String> selectedItems,
    required Function(List<String>) onChanged,
  }) {
    final filtered =
        controller.text.isEmpty
            ? allItems
            : allItems
                .where(
                  (item) => item.toLowerCase().contains(
                    controller.text.toLowerCase(),
                  ),
                )
                .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title Filter',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search $title...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              filtered.map((item) {
                final isSelected = selectedItems.contains(item);
                return FilterChip(
                  label: Text(item),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(selectedItems);
                    selected ? updated.add(item) : updated.remove(item);
                    onChanged(updated.toSet().toList());
                  },
                  showCheckmark: true,
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
