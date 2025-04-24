import 'package:flutter/material.dart';
import 'models/study_material.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/study_material_card.dart';
import '../upload_file/upload_screen.dart';
import '../home/home.dart';

class StudyMaterialsScreen extends StatefulWidget {
  const StudyMaterialsScreen({Key? key}) : super(key: key);

  @override
  State<StudyMaterialsScreen> createState() => _StudyMaterialsState();
}

class _StudyMaterialsState extends State<StudyMaterialsScreen> {
  late List<StudyMaterial> _allMaterials = [];
  late List<StudyMaterial> _filteredMaterials = [];
  late Map<int, String> _universities = {};
  late Map<int, String> _modules = {};

  List<String> _selectedUniversities = [];
  List<String> _selectedYears = [];
  List<String> _selectedTypes = [];
  List<String> _selectedModules = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final materials = await StudyMaterial.getMaterials();
    print(materials[1].university);
    final universities = StudyMaterial.universityMapping;
    print(universities);
    final modules = StudyMaterial.moduleMapping;

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

      _filteredMaterials =
          _allMaterials.where((material) {
            final materialUni = material.universityString;
            final materialYear = material.yearString;
            final materialType = material.typeString;
            final materialModule = material.moduleString;

            bool matchesUniversity =
                _selectedUniversities.isEmpty ||
                (materialUni != null &&
                    _selectedUniversities.contains(materialUni));

            bool matchesYear =
                _selectedYears.isEmpty || _selectedYears.contains(materialYear);
            bool matchesType =
                _selectedTypes.isEmpty || _selectedTypes.contains(materialType);
            bool matchesModule =
                _selectedModules.isEmpty ||
                _selectedModules.contains(materialModule);

            return matchesUniversity &&
                matchesYear &&
                matchesType &&
                matchesModule;
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
    final availableYears = StudyMaterial.getAvailableYears();
    final availableTypes = StudyMaterial.getAvailableTypes();
    final moduleNames = _modules.values.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FilterBottomSheet(
          universities: universityNames,
          years: availableYears,
          types: availableTypes,
          modules: moduleNames,
          selectedUniversities: _selectedUniversities,
          selectedYears: _selectedYears,
          selectedTypes: _selectedTypes,
          selectedModules: _selectedModules,
          onApplyFilters: _applyFilters,
          onClearFilters: _clearFilters,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasActiveFilters =
        _selectedUniversities.isNotEmpty ||
        _selectedYears.isNotEmpty ||
        _selectedTypes.isNotEmpty ||
        _selectedModules.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text('Study Materials'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterBottomSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Materials',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _filteredMaterials =
                      _allMaterials.where((material) {
                        final materialName = material.name?.toLowerCase() ?? '';
                        return materialName.contains(query.toLowerCase());
                      }).toList();
                });
              },
            ),
          ),
          // Show selected filters below the search bar
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ..._selectedUniversities.map(
                    (university) => Chip(
                      label: Text(university),
                      onDeleted: () {
                        setState(() {
                          _selectedUniversities.remove(university);
                          _applyFilters(
                            universities: _selectedUniversities,
                            years: _selectedYears,
                            types: _selectedTypes,
                            modules: _selectedModules,
                          );
                        });
                      },
                    ),
                  ),
                  ..._selectedYears.map(
                    (year) => Chip(
                      label: Text(year),
                      onDeleted: () {
                        setState(() {
                          _selectedYears.remove(year);
                          _applyFilters(
                            universities: _selectedUniversities,
                            years: _selectedYears,
                            types: _selectedTypes,
                            modules: _selectedModules,
                          );
                        });
                      },
                    ),
                  ),
                  ..._selectedTypes.map(
                    (type) => Chip(
                      label: Text(type),
                      onDeleted: () {
                        setState(() {
                          _selectedTypes.remove(type);
                          _applyFilters(
                            universities: _selectedUniversities,
                            years: _selectedYears,
                            types: _selectedTypes,
                            modules: _selectedModules,
                          );
                        });
                      },
                    ),
                  ),
                  ..._selectedModules.map(
                    (module) => Chip(
                      label: Text(module),
                      onDeleted: () {
                        setState(() {
                          _selectedModules.remove(module);
                          _applyFilters(
                            universities: _selectedUniversities,
                            years: _selectedYears,
                            types: _selectedTypes,
                            modules: _selectedModules,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child:
                _filteredMaterials.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No materials match your filters',
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
                            child: StudyMaterialCard(
                              material: material,
                              link: material.materialUrl,
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      bottomNavigationBar: buildNavBar(context, '/search'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Upload New Material',
      ),
    );
  }
}
