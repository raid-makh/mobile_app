import 'package:supabase_flutter/supabase_flutter.dart';

class StudyMaterial {
  final String id;
  final String name;
  final int year;
  final int type;
  final int module;
  final String materialUrl;
  final int? university;
  final String? description;
  final String? userId;

  StudyMaterial({
    required this.id,
    required this.name,
    required this.year,
    required this.type,
    required this.module,
    required this.materialUrl,
    this.university,
    this.description,
    this.userId,
  });

  factory StudyMaterial.fromMap(Map<String, dynamic> map) {
    return StudyMaterial(
      id: map['id'].toString(),
      name: map['name']?.toString() ?? '',
      year: map['year'] as int,
      type: map['type'] as int,
      module: map['module'] as int,
      materialUrl: map['material_url']?.toString() ?? '',
      university: map['university'] as int?,
      description: map['material_description']?.toString(),
      userId: map['user_id']?.toString(),
    );
  }

  /// Static mappings
  static final Map<int, String> yearMapping = {
    1: "2016/2015",
    2: "2017/2016",
    3: "2018/2017",
    4: "2019/2018",
    5: "2020/2019",
    6: "2021/2020",
    7: "2022/2021",
    8: "2023/2022",
    9: "2024/2023",
    10: "2025/2024",
  };

  static final Map<int, String> typeMapping = {
    1: "All-materials-in-1-drive",
    2: "Exam",
    3: "Midterm",
    4: "Test",
    5: "Code Sample",
    6: "Slides",
    7: "Lecture Notes",
    8: "Assignment",
  };

  static var moduleMapping = <int, String>{};
  static var universityMapping = <int, String>{};

  /// Inverse mappings
  static Map<String, int> get yearMappingInverse =>
      yearMapping.map((k, v) => MapEntry(v, k));

  static Map<String, int> get typeMappingInverse =>
      typeMapping.map((k, v) => MapEntry(v, k));

  static Map<String, int> get moduleMappingInverse =>
      moduleMapping.map((k, v) => MapEntry(v, k));

  static Map<String, int> get universityMappingInverse =>
      universityMapping.map((k, v) => MapEntry(v, k));

  /// Display string getters
  String get yearString => yearMapping[year] ?? "Unknown Year";

  String get typeString => typeMapping[type] ?? "Unknown Type";

  String get moduleString => moduleMapping[module] ?? "Unknown Module";

  String? get universityString =>
      university != null
          ? universityMapping[university!] ?? "Unknown University"
          : null;

  /// Dropdown-friendly helpers
  static List<String> getAvailableYears() => yearMapping.values.toList();

  static List<String> getAvailableTypes() => typeMapping.values.toList();

  static List<String> getAvailableModules() => moduleMapping.values.toList();

  static List<String> getAvailableUniversities() =>
      universityMapping.values.toList();

  /// Load mappings from Supabase on app startup
  static Future<void> initMappings() async {
    try {
      final supabase = Supabase.instance.client;

      final universityResponse = await supabase
          .from('universities')
          .select('id, name');
      final moduleResponse = await supabase.from('modules').select('id, name');

      universityMapping = {
        for (var row in universityResponse)
          row['id'] as int: row['name'] as String,
      };

      moduleMapping = {
        for (var row in moduleResponse) row['id'] as int: row['name'] as String,
      };
      print("✅ Mappings initialized from Supabase.");
    } catch (e) {
      print('❌ Failed to load mappings: $e');
    }
  }

  /// Fetch study materials from Supabase
  static Future<List<StudyMaterial>> getMaterials() async {
    try {
      final response = await Supabase.instance.client
          .from('search_library')
          .select('*');

      return (response as List)
          .map((item) => StudyMaterial.fromMap(item))
          .toList();
    } catch (e) {
      print('Error fetching materials: $e');
      return [];
    }
  }
}
