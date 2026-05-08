// tools/seed_data.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:io';

void main() async {
  await Supabase.initialize(
    url: 'https://qvbvyairnithdbewrmnm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF2YnZ5YWlybml0aGRiZXdybW5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjYzOTQsImV4cCI6MjA5MzYwMjM5NH0.469N44eH3P1G5kzYTOTG6cU2abbVvbj2RPlkByRkfZg',
  );
  final supabase = Supabase.instance.client;

  final jsonString = await File('assets/dataset.json').readAsString();
  final data = jsonDecode(jsonString);

  for (var area in data['areas']) {
    await supabase.from('areas').upsert(area);
  }
  for (var compound in data['compounds']) {
    await supabase.from('compounds').upsert(compound);
  }
  for (var prop in data['properties']) {
    await supabase.from('properties').upsert({
      ...prop,
      'images': [prop['images'][0]], // images must be an array
    });
  }
  stdout.writeln('Dataset seeded');
}
