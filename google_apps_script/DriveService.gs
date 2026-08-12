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
  }
};
