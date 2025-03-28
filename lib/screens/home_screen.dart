import 'package:flutter/material.dart';
import 'package:time_tracker/screens/all_entries_screen.dart';
import 'package:time_tracker/screens/grouped_by_project_screen.dart';
import 'package:time_tracker/screens/task_management_screen.dart';
import 'package:time_tracker/screens/time_entry_screen.dart';
import 'package:time_tracker/screens/project_management_screen.dart';
 // Create this screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Time Tracking'),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Entries'),
              Tab(text: 'Grouped by Projects'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: const Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Projects'),
                onTap: () {
                  // Navigate to the projects screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProjectManagementScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.task),
                title: const Text('Tasks'),
                onTap: () {
                  // Navigate to the tasks screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskManagementScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AllEntriesTab(), // Tab 1: All Entries
            GroupedByProjectsTab(), // Tab 2: Grouped by Projects
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the screen to add a new time entry
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
            );
          },
          tooltip: 'Add Time Entry',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}