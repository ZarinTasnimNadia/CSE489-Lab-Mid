// landmark_edit_form.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';                             
import 'dart:typed_data';
import 'package:image/image.dart' as img;     
import 'package:path_provider/path_provider.dart'; // ⭐️ NEW: Required for temporary directory
import 'landmark.dart';
import 'api_service.dart';

class LandmarkEditForm extends StatefulWidget {
  final Landmark landmark;
  final VoidCallback onSuccessfulUpdate; 

  const LandmarkEditForm({
    super.key, 
    required this.landmark, 
    required this.onSuccessfulUpdate,
  });

  @override
  State<LandmarkEditForm> createState() => _LandmarkEditFormState();
}

class _LandmarkEditFormState extends State<LandmarkEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _latController; 
  late TextEditingController _lonController;

  String? _newImageFilePath; 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.landmark.title);
    _latController = TextEditingController(text: widget.landmark.lat.toString());
    _lonController = TextEditingController(text: widget.landmark.lon.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }
  
    
  /// landmark_edit_form.dart (Inside _LandmarkEditFormState)

// ⭐️ FIXED: The type for imageBytes is now explicitly Uint8List
Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    try {
      // 1. Read the file bytes. We explicitly define the type as Uint8List
      final File imageFile = File(pickedFile.path);
      // Change List<int> to Uint8List to match the return type of readAsBytes() and the requirement of decodeImage()
      final Uint8List imageBytes = await imageFile.readAsBytes(); 
      
      // 2. Decode the image using the 'image' package
      // This now correctly accepts the Uint8List
      img.Image? originalImage = img.decodeImage(imageBytes); 
      
      if (originalImage == null) {
        throw Exception("Failed to decode image.");
      }
      
      // 3. Resize the image to 800x600 (Required resolution)
      img.Image resizedImage = img.copyResize(
        originalImage, 
        width: 800, 
        height: 600,
      );
      
      // 4. Encode the resized image back to JPEG bytes
      final List<int> resizedBytes = img.encodeJpg(resizedImage, quality: 90); 

      // 5. Save the resized image to a temporary file path
      final Directory tempDir = await getTemporaryDirectory();
      final String resizedPath = '${tempDir.path}/resized_landmark_${widget.landmark.id}.jpg';
      final File resizedFile = File(resizedPath);

      await resizedFile.writeAsBytes(resizedBytes);
      
      // 6. Update state with the path to the resized file for API service
      setState(() {
        _newImageFilePath = resizedFile.path;
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
      _newImageFilePath = null;
    }
  }
}


  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService().updateLandmark(
          id: widget.landmark.id,
          title: _titleController.text,
          lat: double.parse(_latController.text),
          lon: double.parse(_lonController.text),
          imageFilePath: _newImageFilePath,
        );

        // Success Feedback & Refresh
        widget.onSuccessfulUpdate();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Landmark updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Close the form
        }

      } catch (e) {
        // Error Feedback
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Update Failed'),
              content: Text('Could not update landmark: $e'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
              ],
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 16.0, 
          left: 16.0, 
          right: 16.0,
          // Adjust padding when keyboard is visible
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ), 
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Edit ${widget.landmark.title}', 
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Landmark Title'),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 10),

              // Image Selector Button
              ListTile(
                leading: const Icon(Icons.image_search),
                title: Text(_newImageFilePath == null 
                    ? 'Select New Image (Optional)' 
                    : 'Image Selected! (${_newImageFilePath!.split('/').last})' // Show file name
                ),
                trailing: const Icon(Icons.upload),
                onTap: _pickImage,
              ),
              // Show a small preview if an image is selected (Optional, but helpful)
              if (_newImageFilePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(
                    File(_newImageFilePath!),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),

              // Lat/Lon Fields 
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lonController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
               
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitUpdate,
                child: const Text('Update Landmark'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}