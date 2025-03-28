import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/models/project.dart';
import 'package:time_tracker/models/time_entry.dart';
import 'package:time_tracker/models/task.dart';
import 'package:time_tracker/providers/time_entry_provider.dart';
import 'package:time_tracker/providers/project_task_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddTimeEntryScreenState createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  @override
  Widget build(BuildContext context) {
    final projectTaskProvider = Provider.of<ProjectTaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Dropdown for selecting a project
              DropdownButtonFormField<String>(
                value: projectId,
                onChanged: (String? newValue) async {
                  if (newValue == 'add_new_project') {
                    await _showAddProjectDialog(projectTaskProvider);
                  } else {
                    setState(() {
                      projectId = newValue;
                      taskId = null; // Reset taskId when project changes
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Project'),
                items: [
                  ...projectTaskProvider.projects.map<DropdownMenuItem<String>>(
                    (project) {
                      return DropdownMenuItem<String>(
                        value: project.id,
                        child: Text(project.name),
                      );
                    },
                  ),
                  const DropdownMenuItem<String>(
                    value: 'add_new_project',
                    child: Text('Add New Project'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Dropdown for selecting a task
              DropdownButtonFormField<String>(
                value: taskId,
                onChanged: (String? newValue) async {
                  if (newValue == 'add_new_task') {
                    await _showAddTaskDialog(projectTaskProvider);
                  } else {
                    setState(() {
                      taskId = newValue;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Task'),
                items:
                    projectId == null
                        ? []
                        : [
                          ...projectTaskProvider.projects
                              .firstWhere((project) => project.id == projectId)
                              .tasks
                              .map<DropdownMenuItem<String>>((task) {
                                return DropdownMenuItem<String>(
                                  value: task.id,
                                  child: Text(task.name),
                                );
                              })
                              ,
                          const DropdownMenuItem<String>(
                            value: 'add_new_task',
                            child: Text('Add New Task'),
                          ),
                        ],
              ),
              const SizedBox(height: 16),
              // Total Time field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Total Time (hours)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total time';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => totalTime = double.parse(value!),
              ),
              const SizedBox(height: 16),
              // Notes field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some notes';
                  }
                  return null;
                },
                onSaved: (value) => notes = value!,
              ),
              const SizedBox(height: 16),
              // Save button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Provider.of<TimeEntryProvider>(
                      context,
                      listen: false,
                    ).addTimeEntry(
                      TimeEntry(
                        id: DateTime.now().toString(),
                        projectId: projectId!,
                        taskId: taskId!,
                        totalTime: totalTime,
                        date: date,
                        notes: notes,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddProjectDialog(ProjectTaskProvider provider) async {
    String projectName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Project'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Project Name'),
            onChanged: (value) {
              projectName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (projectName.isNotEmpty) {
                  // Create a new project
                  final newProject = Project(
                    id: DateTime.now().toString(),
                    name: projectName,
                    tasks: [],
                  );
                  provider.addProject(newProject);

                  // Automatically select the newly created project
                  setState(() {
                    projectId = newProject.id;
                    taskId = null; // Reset task selection
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddTaskDialog(ProjectTaskProvider provider) async {
    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project first!')),
      );
      return;
    }

    String taskName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Task Name'),
            onChanged: (value) {
              taskName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (taskName.isNotEmpty) {
                  // Create a new task
                  final newTask = Task(
                    id: DateTime.now().toString(),
                    name: taskName,
                  );
                  provider.addTask(projectId!, newTask);

                  // Automatically select the newly created task
                  setState(() {
                    taskId = newTask.id;
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
