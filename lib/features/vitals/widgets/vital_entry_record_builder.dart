import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/blood_glucose.dart';
import '../../../core/models/blood_pressure.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/heart_rate.dart';
import '../../../core/models/height.dart';
import '../../../core/models/hydration.dart';
import '../../../core/models/oxygen_saturation.dart';
import '../../../core/models/sleep.dart';
import '../../../core/models/temperature.dart';
import '../../../core/models/weight.dart';
import '../../../core/state/module_providers.dart';

/// Turns the keypad's raw digit strings into a real, typed record and
/// appends it via the matching family-parameterised notifier — this is
/// what lets a logged vital actually show up afterwards, rather than the
/// keypad just being a pretty dead end.
void buildAndSaveVitalRecord({
  required WidgetRef ref,
  required String moduleKey,
  required int memberId,
  required Map<String, String> values,
  String? contextTag,
}) {
  final now = DateTime.now();
  final id = now.millisecondsSinceEpoch;
  double d(String key) => double.tryParse(values[key] ?? '') ?? 0;
  int i(String key) => int.tryParse(values[key] ?? '') ?? 0;

  switch (moduleKey) {
    case 'blood_pressure':
      ref.read(bloodPressureProvider(memberId).notifier).addRecord(BloodPressure(
            id: id,
            familyMemberId: memberId,
            systolic: i('systolic'),
            diastolic: i('diastolic'),
            measurementDate: now,
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
    case 'weight':
      ref.read(weightProvider(memberId).notifier).addRecord(Weight(
            id: id,
            familyMemberId: memberId,
            weight: d('weight'),
            unit: WeightUnit.kilograms,
            measurementDate: now,
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
    case 'height':
      ref.read(heightProvider(memberId).notifier).addRecord(Height(
            id: id,
            familyMemberId: memberId,
            height: d('height'),
            unit: HeightUnit.centimeters,
            measurementDate: now,
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
    case 'blood_glucose':
      ref.read(bloodGlucoseProvider(memberId).notifier).addRecord(BloodGlucose(
            id: id,
            familyMemberId: memberId,
            glucose: d('glucose'),
            unit: GlucoseUnit.mgDl,
            measurementDate: now,
            mealContext: _mealContextFor(contextTag),
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
    case 'heart_rate':
      ref.read(heartRateProvider(memberId).notifier).addRecord(HeartRate(
            id: id,
            familyMemberId: memberId,
            bpm: i('bpm'),
            measurementDate: now,
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
    case 'temperature':
      ref.read(temperatureProvider(memberId).notifier).addRecord(Temperature(
            id: id,
            familyMemberId: memberId,
            temperature: d('temperature'),
            unit: TemperatureUnit.celsius,
            measurementDate: now,
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
    case 'oxygen_saturation':
      ref.read(oxygenSaturationProvider(memberId).notifier).addRecord(OxygenSaturation(
            id: id,
            familyMemberId: memberId,
            spO2: d('spo2'),
            measurementDate: now,
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
    case 'sleep':
      ref.read(sleepProvider(memberId).notifier).addRecord(SleepRecord(
            id: id,
            familyMemberId: memberId,
            sleepDate: now,
            hoursSlept: i('hours') + (i('minutes') / 60),
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
    case 'exercise':
      ref.read(exerciseProvider(memberId).notifier).addRecord(Exercise(
            id: id,
            familyMemberId: memberId,
            exerciseDate: now,
            activityType: _exerciseTypeFor(contextTag),
            duration: i('duration'),
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
    case 'hydration':
      ref.read(hydrationProvider(memberId).notifier).addRecord(Hydration(
            id: id,
            familyMemberId: memberId,
            date: now,
            waterIntake: d('ml'),
            unit: VolumeUnit.milliliters,
            notes: contextTag,
            createdAt: now,
            updatedAt: now,
          ));
      return;
  }
}

MealContext? _mealContextFor(String? tag) => switch (tag) {
      'Fasting' => MealContext.fasting,
      'Before meal' => MealContext.beforeMeal,
      'After meal' => MealContext.afterMeal,
      'Random' => MealContext.random,
      _ => null,
    };

ExerciseType _exerciseTypeFor(String? tag) => switch (tag) {
      'Walking' => ExerciseType.walking,
      'Running' => ExerciseType.running,
      'Cycling' => ExerciseType.cycling,
      'Swimming' => ExerciseType.swimming,
      'Gym' => ExerciseType.gym,
      'Yoga' => ExerciseType.yoga,
      'Sports' => ExerciseType.sports,
      _ => ExerciseType.other,
    };
