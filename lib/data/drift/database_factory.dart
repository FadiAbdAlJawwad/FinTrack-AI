import 'dart:io';

import 'package:drift/native.dart';

import 'app_database.dart';

AppDatabase openInMemory() {
  return AppDatabase(NativeDatabase.memory());
}

AppDatabase openFile(File file) {
  return AppDatabase(NativeDatabase.createInBackground(file));
}
