import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/models/project.dart';
import 'package:time_tracker/models/task.dart';
import 'package:time_tracker/providers/project_task_provider.dart';
import 'package:time_tracker/providers/time_entry_provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class AllEntriesTab extends StatelessWidget {
  const AllEntriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final timeEntryProvider = Provider.of<TimeEntryProvider>(context);
    final projectTaskProvider = Provider.of<ProjectTaskProvider>(context);

    if (timeEntryProvider.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No time entries yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add your first entry.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: timeEntryProvider.entries.length,
      itemBuilder: (context, index) {
        final entry = timeEntryProvider.entries[index];

        // Retrieve project and task names
        final project = projectTaskProvider.projects
            .firstWhere((project) => project.id == entry.projectId, orElse: () => Project(id: '', name: 'Unknown Project', tasks: []));
        final task = project.tasks
            .firstWhere((task) => task.id == entry.taskId, orElse: () => Task(id: '', name: 'Unknown Task'));

        final projectName = project.name;
        final taskName = task.name;

        // Format the date
        final formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(entry.date);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  taskName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: $formattedDate',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Time: ${entry.totalTime} hours',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Notes: ${entry.notes}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Delete the time entry
                timeEntryProvider.deleteTimeEntry(entry.id);

                // Show a confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Time entry deleted')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}