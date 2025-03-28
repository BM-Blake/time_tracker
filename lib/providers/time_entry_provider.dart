import 'package:flutter/material.dart';
import 'package:time_tracker/models/time_entry.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage localStorage;
  List<TimeEntry> _entries = [];

  TimeEntryProvider({required this.localStorage}) {
    _loadTimeEntriesFromStorage();
  }

  List<TimeEntry> get entries => _entries; // Public getter for time entries

  void _loadTimeEntriesFromStorage() {
    try {
      final entriesJson = localStorage.getItem('time_entries');
      if (entriesJson != null) {
        _entries = List<TimeEntry>.from(
          jsonDecode(entriesJson).map((entry) => TimeEntry.fromJson(entry)),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading time entries from storage: $e');
    }
  }

  void saveTimeEntries() {
    try {
      final entries = _entries.map((entry) => entry.toJson()).toList();
      localStorage.setItem('time_entries', jsonEncode(entries));
      notifyListeners();
    } catch (e) {
      print('Error saving time entries to storage: $e');
    }
  }

  void addTimeEntry(TimeEntry entry) {
    try {
      _entries.add(entry);
      saveTimeEntries();
    } catch (e) {
      print('Error adding time entry: $e');
    }
  }

  void deleteTimeEntry(String id) {
    try {
      _entries.removeWhere((entry) => entry.id == id);
      saveTimeEntries();
    } catch (e) {
      print('Error deleting time entry: $e');
    }
  }
}