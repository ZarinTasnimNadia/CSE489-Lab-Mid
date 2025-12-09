import 'package:flutter/material.dart';
import 'pages/overview.dart'; 
import 'pages/records.dart'; 
import 'pages/new_entry.dart'; 

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0; 
  
  final List<Widget> _pages = <Widget>[
    const OverviewPage(), 
    const RecordsPage(),  
    const NewEntryPage(),
  ];

  // 3. Method to update the state when a tab is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _pages.elementAt(_selectedIndex), 

      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Overview', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Records', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt_outlined),
            label: 'New Entry', 
          ),
        ],
        currentIndex: _selectedIndex, // Highlights the currently active tab.
        selectedItemColor: null, 
        unselectedItemColor: null, 
        backgroundColor: null, 
        type: BottomNavigationBarType.fixed, // Use this for 3+ items
        onTap: _onItemTapped, // Triggers the state update.
      ),
    );
  }
}