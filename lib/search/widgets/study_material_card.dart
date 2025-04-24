import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_material.dart';

class StudyMaterialCard extends StatelessWidget {
  final StudyMaterial material;
  final String link;

  const StudyMaterialCard({
    Key? key,
    required this.material,
    required this.link,
  }) : super(key: key);

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case "all-materials-in-1-drive":
        return Icons.folder;
      case 'lecture notes':
        return Icons.note;
      case 'exam':
        return Icons.assignment;
      case 'assignment':
        return Icons.assignment_turned_in;
      case 'slides':
        return Icons.slideshow;
      case 'code sample':
        return Icons.code;
      default:
        return Icons.description;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case "all-materials-in-1-drive":
        return Colors.yellow;
      case 'lecture notes':
        return Colors.blue;
      case 'exam':
        return Colors.red;
      case 'assignment':
        return Colors.green;
      case 'slides':
        return Colors.orange;
      case 'code sample':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _launchCustomLink(BuildContext context) async {
    final uri = Uri.tryParse(link);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the link'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addToMyDocuments(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add documents.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await supabase.from('user_documents').insert({
        'user_id': user.id,
        'file_id': material.id, // Assuming this matches `search_library.id`
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${material.name} added to your documents.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add document.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchCustomLink(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getColorForType(
                        material.typeString,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForType(material.typeString),
                      color: _getColorForType(material.typeString),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          material.description ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (material.universityString != null)
                              Chip(
                                label: Text(material.universityString!),
                                backgroundColor: Colors.blue[50],
                                labelStyle: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 12,
                                ),
                              ),
                            Chip(
                              label: Text(material.yearString),
                              backgroundColor: Colors.amber[50],
                              labelStyle: TextStyle(
                                color: Colors.amber[700],
                                fontSize: 12,
                              ),
                            ),
                            Chip(
                              label: Text(material.typeString),
                              backgroundColor: _getColorForType(
                                material.typeString,
                              ).withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: _getColorForType(material.typeString),
                                fontSize: 12,
                              ),
                            ),
                            if (material.moduleString != null)
                              Chip(
                                label: Text(material.moduleString!),
                                backgroundColor: Colors.purple[50],
                                labelStyle: TextStyle(
                                  color: Colors.purple[700],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => _addToMyDocuments(context),
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: const Text("Add to My Documents"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
