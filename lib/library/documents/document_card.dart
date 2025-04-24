import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;
import './document.dart';

class DocumentCard extends StatefulWidget {
  final Document material;
  final String link;

  const DocumentCard({
    Key? key,
    required this.material,
    required this.link,
  }) : super(key: key);

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  bool _isDownloaded = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
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
    final uri = Uri.tryParse(widget.link);
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
  @override
  Widget build(BuildContext context) {
    final material = widget.material;

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
                      color: _getColorForType(material.typeString).withOpacity(0.1),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                material.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),],
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
                              backgroundColor: _getColorForType(material.typeString)
                                  .withOpacity(0.1),
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
