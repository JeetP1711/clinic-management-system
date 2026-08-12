function handleCreatePatient(data) {
  // Validation
  if (!data.full_name || data.full_name.trim() === '') {
    return ResponseHelper.error('Full Name is required');
  }
  if (!data.mobile || data.mobile.trim() === '') {
    return ResponseHelper.error('Mobile Number is required');
  }
  if (!data.date_of_birth) {
    return ResponseHelper.error('Date of Birth is required');
  }
  if (!data.gender) {
    return ResponseHelper.error('Gender is required');
  }

  var sheet = SheetService.getPatientsSheet();
  var mobileClean = data.mobile.toString().trim();

  // Check Duplicate Mobile Number
  var lastRow = sheet.getLastRow();
  if (lastRow > 1) {
    var existingMobiles = sheet.getRange(2, 3, lastRow - 1, 1).getValues();
    for (var i = 0; i < existingMobiles.length; i++) {
      if (existingMobiles[i][0].toString().trim() === mobileClean) {
        return ResponseHelper.error(
          'A patient with mobile number ' + mobileClean + ' already exists.',
          'DUPLICATE_MOBILE'
        );
      }
    }
  }

  // Generate ID
  var patientId = SheetService.generateNextPatientId(sheet);

  // Create Drive Folders
  var driveFolderId = '';
  try {
    driveFolderId = DriveService.createPatientFolderStructure(patientId);
  } catch (driveErr) {
    return ResponseHelper.error('Failed to create patient folder in Google Drive: ' + driveErr.toString());
  }

  // Timestamps
  var nowIso = new Date().toISOString();

  // Record Data
  var patientRecord = [
    patientId,
    data.full_name.trim(),
    mobileClean,
    data.date_of_birth,
    data.gender,
    data.blood_group || '',
    data.email || '',
    data.address || '',
    data.emergency_contact || '',
    data.emergency_contact_name || '',
    'Active',
    nowIso,
    nowIso,
    driveFolderId
  ];

  // Write to Sheets
  try {
    sheet.appendRow(patientRecord);
  } catch (sheetErr) {
    return ResponseHelper.error('Failed to write patient record to Google Sheets: ' + sheetErr.toString());
  }

  // Response Data Object
  var resultObj = {
    patient_id: patientId,
    full_name: data.full_name.trim(),
    mobile: mobileClean,
    date_of_birth: data.date_of_birth,
    gender: data.gender,
    blood_group: data.blood_group || '',
    email: data.email || '',
    address: data.address || '',
    emergency_contact: data.emergency_contact || '',
    emergency_contact_name: data.emergency_contact_name || '',
    status: 'Active',
    created_at: nowIso,
    updated_at: nowIso,
    drive_folder_id: driveFolderId
  };

  return ResponseHelper.success(resultObj, 'Patient created successfully');
}

function handleGetPatients() {
  var sheet = SheetService.getPatientsSheet();
  var lastRow = sheet.getLastRow();

  if (lastRow <= 1) {
    return ResponseHelper.success([], 'No patients found');
  }

  var values = sheet.getRange(2, 1, lastRow - 1, 14).getValues();
  var patients = [];

  for (var i = values.length - 1; i >= 0; i--) { // Reverse order (newest first)
    var row = values[i];
    patients.push({
      patient_id: row[0].toString(),
      full_name: row[1].toString(),
      mobile: row[2].toString(),
      date_of_birth: row[3].toString(),
      gender: row[4].toString(),
      blood_group: row[5].toString(),
      email: row[6].toString(),
      address: row[7].toString(),
      emergency_contact: row[8].toString(),
      emergency_contact_name: row[9].toString(),
      status: row[10].toString(),
      created_at: row[11].toString(),
      updated_at: row[12].toString(),
      drive_folder_id: row[13].toString()
    });
  }

  return ResponseHelper.success(patients);
}

function handleGetPatient(patientId) {
  if (!patientId) {
    return ResponseHelper.error('Patient ID is required');
  }

  var sheet = SheetService.getPatientsSheet();
  var lastRow = sheet.getLastRow();

  if (lastRow <= 1) {
    return ResponseHelper.error('Patient not found');
  }

  var values = sheet.getRange(2, 1, lastRow - 1, 14).getValues();
  for (var i = 0; i < values.length; i++) {
    var row = values[i];
    if (row[0].toString() === patientId) {
      return ResponseHelper.success({
        patient_id: row[0].toString(),
        full_name: row[1].toString(),
        mobile: row[2].toString(),
        date_of_birth: row[3].toString(),
        gender: row[4].toString(),
        blood_group: row[5].toString(),
        email: row[6].toString(),
        address: row[7].toString(),
        emergency_contact: row[8].toString(),
        emergency_contact_name: row[9].toString(),
        status: row[10].toString(),
        created_at: row[11].toString(),
        updated_at: row[12].toString(),
        drive_folder_id: row[13].toString()
      });
    }
  }

  return ResponseHelper.error('Patient not found');
}

function handleSearchPatients(query) {
  if (!query) {
    return handleGetPatients();
  }

  var q = query.toString().toLowerCase().trim();
  var sheet = SheetService.getPatientsSheet();
  var lastRow = sheet.getLastRow();

  if (lastRow <= 1) {
    return ResponseHelper.success([]);
  }

  var values = sheet.getRange(2, 1, lastRow - 1, 14).getValues();
  var matches = [];

  for (var i = values.length - 1; i >= 0; i--) {
    var row = values[i];
    var pId = row[0].toString().toLowerCase();
    var name = row[1].toString().toLowerCase();
    var mobile = row[2].toString().toLowerCase();

    if (pId.indexOf(q) !== -1 || name.indexOf(q) !== -1 || mobile.indexOf(q) !== -1) {
      matches.push({
        patient_id: row[0].toString(),
        full_name: row[1].toString(),
        mobile: row[2].toString(),
        date_of_birth: row[3].toString(),
        gender: row[4].toString(),
        blood_group: row[5].toString(),
        email: row[6].toString(),
        address: row[7].toString(),
        emergency_contact: row[8].toString(),
        emergency_contact_name: row[9].toString(),
        status: row[10].toString(),
        created_at: row[11].toString(),
        updated_at: row[12].toString(),
        drive_folder_id: row[13].toString()
      });
    }
  }

  return ResponseHelper.success(matches);
}
