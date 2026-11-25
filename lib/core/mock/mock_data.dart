import '../models/doctor.dart';

/// Sample doctors. Doctors arrive in a later release; everything else comes from the API.
class MockData {
  MockData._();

  static final _now = DateTime.now();
  static DateTime _daysAgo(int days) => _now.subtract(Duration(days: days));

  // ─── Doctors ──────────────────────────────────────────────────

  static final doctors = [
    Doctor(
      id: 1,
      name: 'Dr. Anita Desai',
      speciality: 'General Physician',
      contactNumber: '9876543210',
      createdAt: _daysAgo(300),
      updatedAt: _daysAgo(30),
    ),
    Doctor(
      id: 2,
      name: 'Dr. Vikram Mehta',
      speciality: 'Cardiologist',
      contactNumber: '9876543211',
      createdAt: _daysAgo(250),
      updatedAt: _daysAgo(15),
    ),
    Doctor(
      id: 3,
      name: 'Dr. Sneha Patel',
      speciality: 'Pediatrician',
      contactNumber: '9876543212',
      createdAt: _daysAgo(200),
      updatedAt: _daysAgo(5),
    ),
    Doctor(
      id: 4,
      name: 'Dr. Rajesh Kumar',
      speciality: 'Dermatologist',
      contactNumber: '9876543213',
      createdAt: _daysAgo(150),
      updatedAt: _daysAgo(10),
    ),
  ];
}
