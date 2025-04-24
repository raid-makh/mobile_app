import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import "../search/models/study_material.dart";
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedUniversityName;
  String? _selectedYear;
  String? _selectedType;
  String? _selectedModuleName;

  File? _selectedFile;
  bool _isUploading = false;
  String? _fileError;

  // Options for dropdowns
  final List<String> _universities = [];
  final List<String> _modules = [];
  final List<String> _yearOptions = StudyMaterial.getAvailableYears();
  final List<String> _typeOptions = StudyMaterial.getAvailableTypes();

  @override
  void initState() {
    super.initState();
    _loadUniversitiesAndModules();
  }

  Future<void> _loadUniversitiesAndModules() async {
    try {
      final universities = StudyMaterial.universityMapping.values.toList();
      final modules =  StudyMaterial.moduleMapping.values.toList();

      setState(() {
        _universities.addAll(universities);
        _modules.addAll(modules);
      });
    } catch (e) {
      print('Error loading universities and modules: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileError = null;
      });
    }
  }

  String _getFileSize(File file) {
    int bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  IconData _getIconForFile(File file) {
    String ext = _getFileExtension(file);
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _uploadMaterial() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFile == null) {
        setState(() {
          _fileError = 'Please select a file to upload';
        });
        return;
      }

      if (_selectedUniversityName == null || _selectedYear == null || _selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isUploading = true;
        _fileError = null;
      });

      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.path.split('/').last}';
        final filePath = 'upload-request/$fileName';
        final fileBytes = await _selectedFile!.readAsBytes();

        // ✅ Correct method to upload raw bytes (Uint8List)
        await Supabase.instance.client.storage
            .from('upload-request')
            .uploadBinary(filePath, fileBytes);

        final fileUrl = Supabase.instance.client.storage
            .from('upload-request')
            .getPublicUrl(filePath);

        final user = Supabase.instance.client.auth.currentUser;
        await Supabase.instance.client.from('upload_requests').insert([
          {
            'name': _titleController.text,
            'year': _selectedYear,
            'type': _selectedType,
            'module': _selectedModuleName, // or _selectedModuleName if using names only
            'university': _selectedUniversityName, // or _selectedUniversityName
            'material_url': fileUrl,
            'description': _descriptionController.text,
            'user_id': user?.id,
          }
        ]);

        if (mounted) {
          setState(() {
            _isUploading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Study material uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading material: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Material',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Enter name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // University Dropdown
                  const Text(
                    'University',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Select university',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    value: _universities.contains(_selectedUniversityName) ? _selectedUniversityName : 'Other',
                    items: [
                      ..._universities.map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      )),
                      const DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value == 'Other') {
                          _selectedUniversityName = ''; // Clear it so user can type
                        } else {
                          _selectedUniversityName = value!;
                        }
                      });
                    },
                    validator: (value) {
                      if ((_selectedUniversityName == null || _selectedUniversityName!.isEmpty) &&
                          (value == null || value.isEmpty)) {
                        return 'Please select a university';
                      }
                      return null;
                    },
                  ),

                  if (_selectedUniversityName == '' || !(_universities.contains(_selectedUniversityName)))
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Enter university name'),
                        onChanged: (value) => _selectedUniversityName = value,
                        validator: (value) {
                          if ((_selectedUniversityName == null || _selectedUniversityName!.isEmpty) &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter the university name';
                          }
                          return null;
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Year Dropdown
                  const Text(
                    'Year',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Select year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    value: _selectedYear,
                    items: _yearOptions.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a year';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Type Dropdown
                  const Text(
                    'Material Type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Select material type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    value: _selectedType != null
                        ? StudyMaterial.typeMapping[_selectedType!]
                        : null,
                    items: _typeOptions.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a material type';
                      }
                      return null;
                    }, onChanged: (String? value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  ),
                  const SizedBox(height: 24),

                  // Module Dropdown
                  const Text(
                    'Module',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Select module',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    value: _modules.contains(_selectedModuleName) ? _selectedModuleName : 'Other',
                    items: [
                      ..._modules.map((module) => DropdownMenuItem(
                        value: module,
                        child: Text(module),
                      )),
                      const DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value == 'Other') {
                          _selectedModuleName = ''; // Prepare for manual entry
                        } else {
                          _selectedModuleName = value!;
                        }
                      });
                    },
                    validator: (value) {
                      if ((_selectedModuleName == null || _selectedModuleName!.isEmpty) &&
                          (value == null || value.isEmpty)) {
                        return 'Please select a module';
                      }
                      return null;
                    },
                  ),

                  if (_selectedModuleName == '' || !_modules.contains(_selectedModuleName))
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Enter module name'),
                        onChanged: (value) => _selectedModuleName = value,
                        validator: (value) {
                          if ((_selectedModuleName == null || _selectedModuleName!.isEmpty) &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter the module name';
                          }
                          return null;
                        },
                      ),
                    ),


                  const SizedBox(height: 24),

                  // Description Field
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Enter description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),

                  // File Upload Section
                  const Text(
                    'Upload File',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _selectedFile == null
                            ? Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.blue[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Take a photo, or',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: _pickFile,
                              child: Text(
                                'browse',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Supported formats: PDF, DOC, DOCX, PPT, PPTX, XLS, XLSX, TXT',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                            : Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getIconForFile(_selectedFile!),
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedFile!.path.split('/').last,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Size: ${_getFileSize(_selectedFile!)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _pickFile,
                              child: Text(
                                'Change file',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Supported formats: PDF, DOC, DOCX, PPT, PPTX, XLS, XLSX, TXT',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_fileError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _fileError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadMaterial,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: _isUploading
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Uploading...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                          : const Text(
                        'Upload the Request',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}