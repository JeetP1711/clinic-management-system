var DriveService = {
  getRootFolder: function() {
    var folders = DriveApp.getFoldersByName(CONFIG.ROOT_FOLDER_NAME);
    if (folders.hasNext()) {
      return folders.next();
    }
    return DriveApp.createFolder(CONFIG.ROOT_FOLDER_NAME);
  },

  getPatientsFolder: function() {
    var root = this.getRootFolder();
    var folders = root.getFoldersByName(CONFIG.PATIENTS_FOLDER_NAME);
    if (folders.hasNext()) {
      return folders.next();
    }
    return root.createFolder(CONFIG.PATIENTS_FOLDER_NAME);
  },

  createPatientFolderStructure: function(patientId) {
    var patientsFolder = this.getPatientsFolder();
    var patientFolder = patientsFolder.createFolder(patientId);
    
    // Subfolders
    patientFolder.createFolder('Reports');
    patientFolder.createFolder('Images');
    patientFolder.createFolder('Documents');
    patientFolder.createFolder('Prescriptions');
    
    return patientFolder.getId();
  },

  getSubfolderNameForType: function(documentType) {
    var type = (documentType || '').toString().trim();
    if (type === 'Prescription') {
      return 'Prescriptions';
    }
    if (['Patient Image', 'X-Ray', 'MRI', 'CT Scan', 'Ultrasound'].indexOf(type) !== -1) {
      return 'Images';
    }
    if (['Lab Report', 'Blood Test', 'ECG', 'Other medical reports'].indexOf(type) !== -1) {
      return 'Reports';
    }
    return 'Documents';
  },

  getOrCreateSubfolder: function(patientFolder, subfolderName) {
    var subfolders = patientFolder.getFoldersByName(subfolderName);
    if (subfolders.hasNext()) {
      return subfolders.next();
    }
    return patientFolder.createFolder(subfolderName);
  },

  uploadDocumentFile: function(patientFolderId, documentType, fileName, mimeType, base64Data) {
    var patientFolder = DriveApp.getFolderById(patientFolderId);
    var subfolderName = this.getSubfolderNameForType(documentType);
    var targetSubfolder = this.getOrCreateSubfolder(patientFolder, subfolderName);

    var bytes = Utilities.base64Decode(base64Data);
    var blob = Utilities.newBlob(bytes, mimeType, fileName);
    var driveFile = targetSubfolder.createFile(blob);

    // Ensure file access URL is available
    var fileId = driveFile.getId();
    var fileUrl = driveFile.getUrl();

    return {
      drive_file_id: fileId,
      drive_folder_id: targetSubfolder.getId(),
      file_url: fileUrl
    };
  }
};
