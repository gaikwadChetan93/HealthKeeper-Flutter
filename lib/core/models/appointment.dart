import 'health_record.dart';
import 'medical_visit.dart';
import 'sync_status.dart';

enum ReminderTime {
  oneHour('1 hour before', 60),
  oneDay('1 day before', 1440),
  twoDays('2 days before', 2880),
  oneWeek('1 week before', 10080);

  final String displayName;
  final int minutesBefore;
  const ReminderTime(this.displayName, this.minutesBefore);
}

class Appointment extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String doctorName;
  final String hospitalName;
  final Department? department;
  final String? purpose;
  final bool reminderEnabled;
  final ReminderTime? reminderTime;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Appointment({
    this.id = 0,
    required this.familyMemberId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.doctorName,
    required this.hospitalName,
    this.department,
    this.purpose,
    this.reminderEnabled = false,
    this.reminderTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
