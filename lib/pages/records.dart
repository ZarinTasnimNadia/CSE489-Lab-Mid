// records_page.dart

import 'package:flutter/material.dart';
import 'package:landmark/api_service.dart';
import 'package:landmark/landmark.dart';
import 'package:landmark/landmark_edit_form.dart';
import 'dart:async'; 
import '../theme_logic.dart'; 
import 'package:provider/provider.dart';

const String _kApiHost = 'https://labs.anontech.info/cse489/t3/';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {

  late Future<List<Landmark>> _landmarksFuture;
  
  @override
  void initState() {
    super.initState();
    _refreshLandmarks();
  }


  void _refreshLandmarks() {
    setState(() {
      _landmarksFuture = ApiService().fetchLandmarks();
    });
  }



  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 88, 28, 99),
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

  
  void _confirmAndDeleteLandmark(Landmark landmark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${landmark.title}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _refreshLandmarks(); 
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); 
                try {
                  await ApiService().deleteLandmark(landmark.id);
                  _showSuccessSnackbar('Landmark "${landmark.title}" deleted successfully!');
                  _refreshLandmarks(); 
                } catch (e) {
                  _showErrorDialog('Deletion Failed', 'Could not delete landmark: $e');
                  _refreshLandmarks(); 
                }
              },
            ),
          ],
        );
      },
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
            onSuccessfulUpdate: _refreshLandmarks, // Refresh after update
          ),
        );
      },
    );
  }



  Widget _buildLandmarkRecordCard(BuildContext context, Landmark landmark) {

    final imageUrl = landmark.imagePath != null 
    ? '$_kApiHost${landmark.imagePath}' 
    : null;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? const Color.fromARGB(255, 219, 151, 221) : Colors.grey[200],
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.image_not_supported, size: 40.0),
                      ),
                    )
                  : Icon(
                      Icons.image, 
                      size: 40.0, 
                      color: Theme.of(context).iconTheme.color,
                    ),
            ),
            const SizedBox(width: 15),
            
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    landmark.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Latitude
                  Text(
                    'Latitude: ${landmark.lat.toStringAsFixed(6)} N',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                    ),
                  ),
                  // Longitude
                  Text(
                    'Longitude: ${landmark.lon.toStringAsFixed(6)} E',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildList(List<Landmark> landmarks) {
    if (landmarks.isEmpty) {
      return const Center(child: Text('No landmarks found.'));
    }

    return ListView.builder(
      itemCount: landmarks.length,
      itemBuilder: (context, index) {
        final landmark = landmarks[index];
        final Key itemKey = ValueKey(landmark.id); 

        return Dismissible( 
          key: itemKey,
          direction: DismissDirection.horizontal,
          
          
            background: Container(
            color: Theme.of(context).cardColor,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
            ),
            
            
            secondaryBackground: Container(
            color: Theme.of(context).cardColor,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Theme.of(context).iconTheme.color),
            ),
          
          
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) { // Swipe Right to Left (Delete)
              _confirmAndDeleteLandmark(landmark);
              return false;
            } else if (direction == DismissDirection.startToEnd) { // Swipe Left to Right (Edit)
              _showEditForm(landmark);
              return false; // Prevent dismissal; we show the form instead
            }
            return false;
          },
          
          
          child: _buildLandmarkRecordCard(context, landmark),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeLogic>().toggleTheme(),
          ),
        ],
      ),
      body: FutureBuilder<List<Landmark>>(
        future: _landmarksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading records: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildList(snapshot.data!); // Build the scrollable list
          }
          return const Center(child: Text('No records found.'));
        },
      ),
    );
  }
}