import 'package:flutter/material.dart';

import 'field_descriptor.dart';

enum ModuleCategory { quickHealth, vitalOverview }

abstract class DomainConfig {
  String get domainName;
  String get domainKey;
  IconData get icon;
  ModuleCategory get category;
  String get sortField;
  String get shortDescription;
  String get emptyStateTitle;
  String get emptyStateDescription;
  String get emptyStateCTA;
  List<FieldDescriptor> get fields;
}
