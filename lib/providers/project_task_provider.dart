import 'package:flutter/material.dart';
import 'package:time_tracker/models/task.dart';
import 'package:time_tracker/models/project.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class ProjectTaskProvider with ChangeNotifier {
  final LocalStorage localStorage;
  List<Project> _projects = [];

  ProjectTaskProvider({required this.localStorage}) {
    _loadProjectsFromStorage();
  }

  List<Project> get projects => _projects; // Public getter for projects

  void _loadProjectsFromStorage() {
    try {
      final projectsJson = localStorage.getItem('projects');
      if (projectsJson != null) {
        _projects = List<Project>.from(
          jsonDecode(projectsJson).map((project) => Project.fromJson(project)),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading projects from storage: $e');
    }
  }

  void saveProjects() {
    try {
      final projects = _projects.map((project) => project.toJson()).toList();
      localStorage.setItem('projects', jsonEncode(projects));
      notifyListeners();
    } catch (e) {
      print('Error saving projects to storage: $e');
    }
  }

  void addProject(Project project) {
    _projects.add(project);
    saveProjects();
  }

  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    saveProjects();
  }

  void addTask(String projectId, Task task) {
    try {
      final project = _projects.firstWhere(
        (project) => project.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );
      project.tasks.add(task);
      saveProjects();
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  void deleteTask(String projectId, String taskId) {
    try {
      final project = _projects.firstWhere(
        (project) => project.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );
      project.tasks.removeWhere((task) => task.id == taskId);
      saveProjects();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Task? getTask(String projectId, String taskId) {
    try {
      final project = _projects.firstWhere(
        (project) => project.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );
      return project.tasks.firstWhere(
        (task) => task.id == taskId,
        orElse: () => throw Exception('Task not found'),
      );
    } catch (e) {
      print('Error getting task: $e');
      return null;
    }
  }
}