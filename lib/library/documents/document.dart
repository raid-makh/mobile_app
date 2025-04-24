import 'package:supabase_flutter/supabase_flutter.dart';

class Document {
  final String id;
  final String name;
  final int year;
  final int type;
  final int module;
  final String materialUrl;
  final int? university;
  final String? description;
  final String? userId;

  Document({
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

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
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
    1: "Assignment",
    2: "Exam",
    3: "Midterm",
    4: "Test",
    5: "Code Sample",
    6: "Slides",
    7: "Lecture Notes",
  };

  static Map<int, String> moduleMapping = {};
  static Map<int, String> universityMapping = {};

  static Map<String, int> get yearMappingInverse =>
      yearMapping.map((k, v) => MapEntry(v, k));

  static Map<String, int> get typeMappingInverse =>
      typeMapping.map((k, v) => MapEntry(v, k));

  static Map<String, int> get moduleMappingInverse =>
      moduleMapping.map((k, v) => MapEntry(v, k));

  static Map<String, int> get universityMappingInverse =>
      universityMapping.map((k, v) => MapEntry(v, k));

  String get yearString => yearMapping[year] ?? "Unknown Year";
  String get typeString => typeMapping[type] ?? "Unknown Type";
  String get moduleString => moduleMapping[module] ?? "Unknown Module";

  String? get universityString => university != null
      ? universityMapping[university!] ?? "Unknown University"
      : null;

  static List<String> getAvailableYears() => yearMapping.values.toList();
  static List<String> getAvailableTypes() => typeMapping.values.toList();
  static List<String> getAvailableModules() => moduleMapping.values.toList();
  static List<String> getAvailableUniversities() => universityMapping.values.toList();

  static Future<void> initMappings() async {
    try {
      final uniResponse = await Supabase.instance.client
          .from('universities')
          .select('id, name');

      universityMapping = {
        for (var uni in uniResponse) uni['id'] as int: uni['name'] as String,
      };

      final moduleResponse = await Supabase.instance.client
          .from('modules')
          .select('id, name');

      moduleMapping = {
        for (var mod in moduleResponse) mod['id'] as int: mod['name'] as String,
      };

      print('✅ Mappings initialized from Supabase.');
    } catch (e) {
      print('❌ Failed to load mappings: $e');
    }
  }

  /// Fetch user documents (linked study materials)
  static Future<List<Document>> getUserDocuments() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        return [];
      }

      final response = await Supabase.instance.client
          .from('user_documents')
          .select('search_library(*)')
          .eq('user_id', userId);

      final materialList = response as List;
      return materialList
          .map((item) => Document.fromMap(item['search_library']))
          .toList();
    } catch (e) {
      print('❌ Error fetching user documents: $e');
      return [];
    }
  }
}
