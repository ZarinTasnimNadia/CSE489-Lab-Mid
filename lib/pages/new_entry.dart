import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_logic.dart'; 
import '../api_service.dart';
import '../landmark.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';                             
import 'dart:typed_data';                      
import 'package:image/image.dart' as img;     
import 'package:path_provider/path_provider.dart'; 
import 'package:geolocator/geolocator.dart'; 


const double _kInitialLat = 23.6850; 
const double _kInitialLon = 90.3563; 

enum FormMode { ADD, EDIT }

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final _formKey = GlobalKey<FormState>();
  

  late TextEditingController _titleController;
  late TextEditingController _latController; 
  late TextEditingController _lonController;

  String? _newImageFilePath; 
  FormMode _currentMode = FormMode.ADD;
  Landmark? _landmarkToEdit;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    

    _latController = TextEditingController(text: _kInitialLat.toString());
    _lonController = TextEditingController(text: _kInitialLon.toString());


    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }
  

  Future<void> _getCurrentLocation({bool forceUpdate = false}) async {
    if (_currentMode != FormMode.ADD && !forceUpdate) return;

    try {

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }


      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are permanently denied or denied.');
        }
      }
      

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,

      );
      

      if (mounted) {
        setState(() {
          _latController.text = position.latitude.toStringAsFixed(6);
          _lonController.text = position.longitude.toStringAsFixed(6);
        });
      }
      
    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get GPS location: $e')),
        );
      }

    }
  }


  void _switchToAddMode() {
    setState(() {
      _currentMode = FormMode.ADD;
      _landmarkToEdit = null;
      _titleController.clear();
      _newImageFilePath = null;
    });
    

    _getCurrentLocation();
  }
  

  void _switchToEditMode(Landmark landmark) {
    setState(() {
      _currentMode = FormMode.EDIT;
      _landmarkToEdit = landmark;
      _titleController.text = landmark.title;
      _latController.text = landmark.lat.toString();
      _lonController.text = landmark.lon.toString();
      _newImageFilePath = null; 
    });
  }


  void _handleOperationComplete() {
    if (_currentMode == FormMode.ADD) {
      
      _switchToAddMode();
    }
  }


  String? _coordinateValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Coordinate is required';
    }
    if (double.tryParse(value) == null) {
      return 'Must be a valid number';
    }
    return null;
  }
    
 
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery); 

    if (pickedFile != null) {
      try {
        final File imageFile = File(pickedFile.path);
        final Uint8List imageBytes = await imageFile.readAsBytes(); 
        
        img.Image? originalImage = img.decodeImage(imageBytes); 
        
        if (originalImage == null) {
          throw Exception("Failed to decode image.");
        }
        
        // Resize image to 800x600 
        img.Image resizedImage = img.copyResize(
          originalImage, 
          width: 800, 
          height: 600,
        );
        
        final List<int> resizedBytes = img.encodeJpg(resizedImage, quality: 90); 

        final Directory tempDir = await getTemporaryDirectory();
        final String resizedPath = '${tempDir.path}/resized_temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File resizedFile = File(resizedPath);

        await resizedFile.writeAsBytes(resizedBytes);
        
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


  Future<void> _submitOperation() async {
  if (!_formKey.currentState!.validate()) {
    return; 
  }
  

  if (_currentMode == FormMode.ADD && _newImageFilePath == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image is required for new entries.')),
    );
    return;
  }

  try {
    final title = _titleController.text;
    final lat = double.parse(_latController.text);
    final lon = double.parse(_lonController.text);
    
    String successMessage = '';

    if (_currentMode == FormMode.ADD) {

      await ApiService().createLandmark(
        title: title,
        lat: lat,
        lon: lon,
        imageFilePath: _newImageFilePath!,
      );
      successMessage = 'New Landmark added successfully!';
      
    } else {

      await ApiService().updateLandmark(
        id: _landmarkToEdit!.id,
        title: title,
        lat: lat,
        lon: lon,
        imageFilePath: _newImageFilePath, 
      );
      successMessage = 'Landmark updated successfully!';
      

      setState(() {
         _newImageFilePath = null; 
      });
    }


    _handleOperationComplete(); 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: const Color.fromARGB(255, 174, 111, 195)),
      );
    }

  } catch (e) {

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${_currentMode == FormMode.ADD ? 'Creation' : 'Update'} Failed'),
          content: Text('Error: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        ),
      );
    }
  }
}


  Widget _buildLandmarkSelectionDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Landmark to Edit'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<Landmark>>(
          future: ApiService().fetchLandmarks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No landmarks available for editing.'));
            }

            final landmarks = snapshot.data!;
            
            return ListView.builder(
              shrinkWrap: true,
              itemCount: landmarks.length,
              itemBuilder: (context, index) {
                final landmark = landmarks[index];
                return ListTile(
                  title: Text(landmark.title),
                  subtitle: Text('ID: ${landmark.id}, Lat: ${landmark.lat.toStringAsFixed(4)}'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close dialog
                    _switchToEditMode(landmark); // Switch form to EDIT mode
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeLogic>();
    

    final isAddMode = _currentMode == FormMode.ADD;
    final String primaryButtonText = isAddMode ? 'Add Landmark' : 'Update Landmark';
    final String appBarTitle = isAddMode ? 'New Entry' : 'Edit Entry (ID: ${_landmarkToEdit?.id})';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Refresh GPS button
          if (isAddMode)
            IconButton(
              icon: const Icon(Icons.gps_fixed), 
              tooltip: 'Get Current GPS Location',
              onPressed: () => _getCurrentLocation(forceUpdate: true), // Force update location
            ),

          if (isAddMode)
            IconButton(
              icon: const Icon(Icons.mode_edit), 
              tooltip: 'Update Existing Landmark',
              onPressed: () => showDialog(
                context: context, 
                builder: (context) => _buildLandmarkSelectionDialog(context),
              ),
            ),

          if (!isAddMode)
            IconButton(
              icon: const Icon(Icons.cancel), 
              tooltip: 'Cancel Edit and Add New',
              onPressed: _switchToAddMode,
            ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeLogic>().toggleTheme(), 
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 16.0, 
            left: 16.0, 
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ), 
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Image Selector
                ListTile(
                  leading: const Icon(Icons.image_search),
                  title: Text(_newImageFilePath == null 
                      ? (isAddMode ? 'Select Image (Required)' : 'Select New Image (Optional)') 
                      : 'Image Selected! (${_newImageFilePath!.split('/').last})'
                  ),
                  trailing: const Icon(Icons.upload),
                  onTap: _pickImage,
                ),
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

                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Landmark Title'),
                  validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 10),

                // Latitude Field
                TextFormField(
                  controller: _latController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _coordinateValidator,
                ),
                const SizedBox(height: 10),
                
                // Longitude Field
                TextFormField(
                  controller: _lonController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _coordinateValidator,
                ),
                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitOperation,
                  child: Text(primaryButtonText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}