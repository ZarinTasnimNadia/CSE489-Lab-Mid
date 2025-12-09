import 'package:flutter/material.dart';
import 'package:landmark/landmark_edit_form.dart';
import 'package:provider/provider.dart';
import '../theme_logic.dart'; 
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../api_service.dart'; 
import '../landmark.dart';  


const LatLng _kBangladeshCenter = LatLng(23.6850, 90.3563);
const String _kApiHost = 'https://labs.anontech.info/cse489/t3/';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {

  late Future<List<Landmark>> _landmarksFuture;
  Landmark? _selectedLandmark; 

  @override
  void initState() {
    super.initState();

    _landmarksFuture = ApiService().fetchLandmarks();
  }
  

  void _refreshLandmarks() {
    setState(() {
      _landmarksFuture = ApiService().fetchLandmarks();
      _selectedLandmark = null; 
    });
  }


  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 108, 48, 116),
      ),
    );
  }


  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  void _showEditForm(Landmark landmark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (BuildContext context) {
        return Padding(

          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: LandmarkEditForm(
            landmark: landmark,
            onSuccessfulUpdate: _refreshLandmarks, 
          ),
        );
      },
    );
  }


  void _confirmAndDeleteLandmark(Landmark landmark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${landmark.title}"? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                try {
                  await ApiService().deleteLandmark(landmark.id);
                  _showSuccessSnackbar('Landmark "${landmark.title}" deleted successfully!');
                  _refreshLandmarks(); 
                } catch (e) {
                  _showErrorDialog('Deletion Failed', 'Could not delete landmark: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }
  

  Widget _buildSelectLandmarkText(BuildContext context) {
    return Text(
      'Select a Landmark',
      style: TextStyle(
        fontSize: 25, 
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }


 
  Widget _buildLandmarkDetailsCard(Landmark landmark) {

    final imageUrl = landmark.imagePath != null 
    ? '$_kApiHost${landmark.imagePath}' 
    : null;

      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 30.0),
                )
              : Icon(
                  Icons.image, 
                  size: 40.0, 
                  color: Theme.of(context).iconTheme.color,
                ),
        ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                  'Location: ${landmark.title}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  ),
                  Text(
                  'Longitude: ${landmark.lon.toStringAsFixed(4)} E',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  Text(
                  'Latitude: ${landmark.lat.toStringAsFixed(4)} N',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ],
              ),
            ),
            // Quick action buttons
            IconButton(icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color), onPressed: () => _showEditForm(landmark)),
            IconButton(icon: Icon(Icons.delete, color: Theme.of(context).iconTheme.color), onPressed: () => _confirmAndDeleteLandmark(landmark)),
          ],
        );
  }

 
  
  Widget _buildBottomPanel(BuildContext context, bool isDark) {
  
    final infoPanelHeight = _selectedLandmark != null ? 150.0 : 100.0;
    
    return Container(
      height: infoPanelHeight,
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color.fromARGB(255, 220, 31, 144) : const Color.fromARGB(255, 236, 166, 231)
          )
        ),
      ),
      child: Center(
        child: _selectedLandmark != null 
            ? _buildLandmarkDetailsCard(_selectedLandmark!)
            : _buildSelectLandmarkText(context),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeLogic>();
    final bool isDark = themeProvider.isDarkMode;

  
    final String tileUrl = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    
    const List<String> subdomains = ['a', 'b', 'c', 'd']; 
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeLogic>().toggleTheme(),
          ),
        ],
      ),
      
      body: Column(
        children: [
          
          Expanded(
            child: FutureBuilder<List<Landmark>>(
              future: _landmarksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  
                  return Center(child: Text('Error loading landmarks: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final landmarks = snapshot.data!;
                  

                  return FlutterMap(
                    options: const MapOptions(
                      initialCenter: _kBangladeshCenter,
                      initialZoom: 8.0, 
                      interactionOptions: InteractionOptions(flags: InteractiveFlag.all)
                    ),
                    children: [
                      // Tile Layer
                      TileLayer(
                        urlTemplate: tileUrl,
                        userAgentPackageName: 'com.landmarks.app', 
                        subdomains: isDark ? subdomains : const [], 
                      ),


                      MarkerLayer(
                        markers: landmarks.map((landmark) {
                          return Marker(
                            width: 80.0,
                            height: 80.0,
                            point: landmark.coordinates,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                
                                setState(() {
                                  _selectedLandmark = landmark;
                                });
                              },
                              child: Icon(
                                Icons.location_on,
                                
                                color: _selectedLandmark?.id == landmark.id 
                                    ? const Color.fromARGB(255, 172, 12, 116) 
                                    : isDark ? Colors.white : Colors.black,
                                size: 40,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
                return const Center(child: Text('No landmarks found.'));
              },
            ),
          ),
          
          // Bottom info panel
          _buildBottomPanel(context, isDark),
        ],
      ),
    );
  }
}