/// The field of each module that names a doctor (same map as the server's
/// DOCTOR_FIELDS). A record can be linked to a saved doctor through it.
const doctorFields = {
  'medical_visit': 'doctorName',
  'appointment': 'doctorName',
  'prescription': 'prescribedBy',
  'medication': 'prescribedBy',
  'surgery': 'surgeon',
  'medical_history': 'treatedBy',
  'vaccine': 'administeredBy',
  'radiology_result': 'orderedBy',
};

/// Form-state key holding the linked doctor's id (not a module field).
const doctorIdKey = '_doctorId';
