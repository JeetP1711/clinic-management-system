function handleUploadDocument(data) {
  if (!data.patient_id || data.patient_id.trim() === '') {
    return ResponseHelper.error('Patient ID is required');
  }
  if (!data.file_name || data.file_name.trim() === '') {
    return ResponseHelper.error('File name is required');
  }
  if (!data.mime_type || data.mime_type.trim() === '') {
    return ResponseHelper.error('MIME type is required');
  }
  if (!data.file_data || data.file_data.trim() === '') {
    return ResponseHelper.error('File binary data is required');
  }
  if (!data.document_type || data.document_type.trim() === '') {
    return ResponseHelper.error('Document Type is required');
  }

  // Find Patient and get drive_folder_id
  var patientsSheet = SheetService.getPatientsSheet();
  var pLastRow = patientsSheet.getLastRow();
  var driveFolderId = '';

  if (pLastRow > 1) {
    var pValues = patientsSheet.getRange(2, 1, pLastRow - 1, 14).getValues();
    for (var i = 0; i < pValues.length; i++) {
      if (pValues[i][0].toString() === data.patient_id.toString()) {
        driveFolderId = pValues[i][13].toString();
        break;
      }
    }
  }

  if (!driveFolderId) {
    // Attempt folder recovery/creation if folder ID missing
    try {
      driveFolderId = DriveService.createPatientFolderStructure(data.patient_id.toString());
    } catch (e) {
      return ResponseHelper.error('Patient Google Drive folder not found: ' + e.toString());
    }
  }

  // Upload to Drive
  var uploadResult;
  try {
    uploadResult = DriveService.uploadDocumentFile(
      driveFolderId,
      data.document_type,
      data.file_name,
      data.mime_type,
      data.file_data
    );
  } catch (driveErr) {
    return ResponseHelper.error('Failed to upload file to Google Drive: ' + driveErr.toString());
  }

  var docsSheet = SheetService.getDocumentsSheet();
  var documentId = SheetService.generateNextDocumentId(docsSheet);
  var nowIso = new Date().toISOString();
  var documentDate = data.document_date || nowIso.substring(0, 10);

  var docRecord = [
    documentId,
    data.patient_id.toString(),
    data.file_name.trim(),
    data.file_type || data.file_name.split('.').pop() || '',
    data.mime_type.trim(),
    data.document_type.trim(),
    uploadResult.drive_file_id,
    uploadResult.drive_folder_id,
    uploadResult.file_url,
    documentDate,
    data.related_visit_id || '',
    data.notes || '',
    data.uploaded_by || 'Dr. Jeet Patel',
    nowIso,
    data.file_size || 0,
    'Active'
  ];

  try {
    docsSheet.appendRow(docRecord);
  } catch (sheetErr) {
    return ResponseHelper.error(
      'The file was uploaded to Drive, but we couldn\'t save the document record to Sheets. Drive File ID: ' + uploadResult.drive_file_id,
      'SHEET_WRITE_ERROR'
    );
  }

  var docObj = {
    document_id: documentId,
    patient_id: data.patient_id.toString(),
    file_name: data.file_name.trim(),
    file_type: data.file_type || data.file_name.split('.').pop() || '',
    mime_type: data.mime_type.trim(),
    document_type: data.document_type.trim(),
    drive_file_id: uploadResult.drive_file_id,
    drive_folder_id: uploadResult.drive_folder_id,
    file_url: uploadResult.file_url,
    document_date: documentDate,
    related_visit_id: data.related_visit_id || '',
    notes: data.notes || '',
    uploaded_by: data.uploaded_by || 'Dr. Jeet Patel',
    uploaded_at: nowIso,
    file_size: data.file_size || 0,
    status: 'Active'
  };

  return ResponseHelper.success(docObj, 'Document uploaded successfully');
}

function handleGetPatientDocuments(patientId) {
  if (!patientId) {
    return ResponseHelper.error('Patient ID is required');
  }

  var docsSheet = SheetService.getDocumentsSheet();
  var lastRow = docsSheet.getLastRow();

  if (lastRow <= 1) {
    return ResponseHelper.success([], 'No documents found');
  }

  var values = docsSheet.getRange(2, 1, lastRow - 1, 16).getValues();
  var documents = [];

  for (var i = values.length - 1; i >= 0; i--) {
    var row = values[i];
    var rowPatientId = row[1].toString();
    var rowStatus = row[15].toString();

    if (rowPatientId === patientId.toString() && rowStatus !== 'Deleted') {
      documents.push({
        document_id: row[0].toString(),
        patient_id: row[1].toString(),
        file_name: row[2].toString(),
        file_type: row[3].toString(),
        mime_type: row[4].toString(),
        document_type: row[5].toString(),
        drive_file_id: row[6].toString(),
        drive_folder_id: row[7].toString(),
        file_url: row[8].toString(),
        document_date: row[9].toString(),
        related_visit_id: row[10].toString(),
        notes: row[11].toString(),
        uploaded_by: row[12].toString(),
        uploaded_at: row[13].toString(),
        file_size: parseInt(row[14] || 0, 10),
        status: row[15].toString()
      });
    }
  }

  return ResponseHelper.success(documents);
}

function handleUpdateDocument(data) {
  if (!data.document_id) {
    return ResponseHelper.error('Document ID is required');
  }

  var docsSheet = SheetService.getDocumentsSheet();
  var lastRow = docsSheet.getLastRow();

  if (lastRow <= 1) {
    return ResponseHelper.error('Document not found');
  }

  var values = docsSheet.getRange(2, 1, lastRow - 1, 16).getValues();
  for (var i = 0; i < values.length; i++) {
    if (values[i][0].toString() === data.document_id.toString()) {
      var rowIndex = i + 2;
      if (data.document_type) docsSheet.getRange(rowIndex, 6).setValue(data.document_type);
      if (data.document_date) docsSheet.getRange(rowIndex, 10).setValue(data.document_date);
      if (data.related_visit_id !== undefined) docsSheet.getRange(rowIndex, 11).setValue(data.related_visit_id);
      if (data.notes !== undefined) docsSheet.getRange(rowIndex, 12).setValue(data.notes);

      return ResponseHelper.success({ document_id: data.document_id }, 'Document updated successfully');
    }
  }

  return ResponseHelper.error('Document not found');
}

function handleDeleteDocument(data) {
  if (!data.document_id) {
    return ResponseHelper.error('Document ID is required');
  }

  var docsSheet = SheetService.getDocumentsSheet();
  var lastRow = docsSheet.getLastRow();

  if (lastRow <= 1) {
    return ResponseHelper.error('Document not found');
  }

  var values = docsSheet.getRange(2, 1, lastRow - 1, 16).getValues();
  for (var i = 0; i < values.length; i++) {
    if (values[i][0].toString() === data.document_id.toString()) {
      var rowIndex = i + 2;
      var driveFileId = values[i][6].toString();

      // Soft delete in sheet
      docsSheet.getRange(rowIndex, 16).setValue('Deleted');

      // Trash file in Drive if accessible
      try {
        if (driveFileId) {
          var file = DriveApp.getFileById(driveFileId);
          file.setTrashed(true);
        }
      } catch (e) {
        // Log warning but allow document status to update
      }

      return ResponseHelper.success({ document_id: data.document_id }, 'Document deleted successfully');
    }
  }

  return ResponseHelper.error('Document not found');
}
