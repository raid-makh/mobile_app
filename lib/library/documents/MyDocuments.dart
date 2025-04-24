import 'package:flutter/material.dart';
import './document.dart'; // changed from study_material.dart
import './document_card.dart'; // changed from study_material_card.dart

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _StudyMaterialsState();
}

class _StudyMaterialsState extends State<DocumentsScreen> {
  late List<Document> _allMaterials = [];
  late List<Document> _filteredMaterials = [];
  late Map<int, String> _universities = {};
  late Map<int, String> _modules = {};

  List<String> _selectedUniversities = [];
  List<String> _selectedYears = [];
  List<String> _selectedTypes = [];
  List<String> _selectedModules = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final materials = await Document.getUserDocuments();
    final universities = Document.universityMapping;
    final modules = Document.moduleMapping;

    setState(() {
      _allMaterials = materials;
      _filteredMaterials = List.from(materials);
      _universities = universities;
      _modules = modules;
    });
  }

  void _applyFilters({
    required List<String> universities,
    required List<String> years,
    required List<String> types,
    required List<String> modules,
  }) {
    setState(() {
      _selectedUniversities = universities;
      _selectedYears = years;
      _selectedTypes = types;
      _selectedModules = modules;

      _filteredMaterials = _allMaterials.where((material) {
        final materialUni = material.universityString;
        final materialYear = material.yearString;
        final materialType = material.typeString;
        final materialModule = material.moduleString;

        bool matchesUniversity = _selectedUniversities.isEmpty ||
            (materialUni != null && _selectedUniversities.contains(materialUni));
        bool matchesYear = _selectedYears.isEmpty ||
            _selectedYears.contains(materialYear);
        bool matchesType = _selectedTypes.isEmpty ||
            _selectedTypes.contains(materialType);
        bool matchesModule = _selectedModules.isEmpty ||
            _selectedModules.contains(materialModule);

        return matchesUniversity && matchesYear && matchesType && matchesModule;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedUniversities = [];
      _selectedYears = [];
      _selectedTypes = [];
      _selectedModules = [];
      _filteredMaterials = List.from(_allMaterials);
    });
  }

  void _showFilterBottomSheet() {
    final universityNames = _universities.values.toList();
    final availableYears = Document.getAvailableYears();
    final availableTypes = Document.getAvailableTypes();
    final moduleNames = _modules.values.toList();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('My Documents'),
      ),
      body: _filteredMaterials.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No materials are saved',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredMaterials.length,
          itemBuilder: (context, index) {
            final material = _filteredMaterials[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DocumentCard(
                material: material,
                link: material.materialUrl,
              ),
            );
          },
        ),
      ),
    );
  }
}
