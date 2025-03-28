import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/providers/project_task_provider.dart';
import 'package:time_tracker/providers/time_entry_provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class GroupedByProjectsTab extends StatelessWidget {
  const GroupedByProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(context);
    final timeEntryProvider = Provider.of<TimeEntryProvider>(context);

    if (projectProvider.projects.isEmpty) {
      return const Center(
        child: Text(
          'No projects available!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: projectProvider.projects.length,
      itemBuilder: (context, projectIndex) {
        final project = projectProvider.projects[projectIndex];

        // Filter time entries for this project
        final projectTimeEntries = timeEntryProvider.entries
            .where((entry) => entry.projectId == project.id)
            .toList();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Name
                Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                // List of Tasks with Time Entries
                ...projectTimeEntries.map((entry) {
                  // Format the date
                  final formattedDate = DateFormat('MMM dd, yyyy').format(entry.date);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '- ${projectProvider.getTask(entry.projectId,entry.taskId)?.name}: ${entry.totalTime} hours ($formattedDate)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}