#!/usr/bin/env dart

import 'dart:io';

void main() {
  final pubspecFile = File('pubspec.yaml');
  
  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  // Read pubspec.yaml
  final content = pubspecFile.readAsStringSync();
  
  // Find version line: version: 2.0.0+1
  final versionRegex = RegExp(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)$', multiLine: true);
  final match = versionRegex.firstMatch(content);
  
  if (match == null) {
    print('Error: Could not find version line in pubspec.yaml');
    print('Expected format: version: X.Y.Z+BUILD');
    exit(1);
  }

  final version = match.group(1)!; // e.g., "2.0.0"
  final buildNumber = int.parse(match.group(2)!); // e.g., 1
  
  // Increment build number
  final newBuildNumber = buildNumber + 1;
  final newVersion = '$version+$newBuildNumber';
  
  print('Current version: $version+$buildNumber');
  print('New version: $newVersion');
  
  // Replace version line
  final newContent = content.replaceFirst(
    versionRegex,
    'version: $newVersion',
  );
  
  // Write back to file
  pubspecFile.writeAsStringSync(newContent);
  
  print('✅ Updated pubspec.yaml: version: $newVersion');
}

