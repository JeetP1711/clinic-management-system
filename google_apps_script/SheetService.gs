var CONFIG = {
  SPREADSHEET_NAME: 'ClinicOS Database',
  ROOT_FOLDER_NAME: 'ClinicOS Storage',
  PATIENTS_FOLDER_NAME: 'Patients'
};

var SheetService = {
  getSpreadsheet: function() {
    var files = DriveApp.getFilesByName(CONFIG.SPREADSHEET_NAME);
    if (files.hasNext()) {
      var file = files.next();
      return SpreadsheetApp.openById(file.getId());
    }
    // Auto-create if not found
    var ss = SpreadsheetApp.create(CONFIG.SPREADSHEET_NAME);
    this.ensureTabs(ss);
    return ss;
  },

  ensureTabs: function(ss) {
    var tabs = ['Patients', 'Appointments', 'Visits', 'Vitals', 'Prescriptions', 'Documents', 'Bills', 'Users', 'Queue'];
    tabs.forEach(function(tabName) {
      var sheet = ss.getSheetByName(tabName);
      if (!sheet) {
        sheet = ss.insertSheet(tabName);
        if (tabName === 'Patients') {
          sheet.appendRow([
            'patient_id', 'full_name', 'mobile', 'date_of_birth', 'gender',
            'blood_group', 'email', 'address', 'emergency_contact',
            'emergency_contact_name', 'status', 'created_at', 'updated_at', 'drive_folder_id'
          ]);
          sheet.getRange(1, 1, 1, 14).setFontWeight('bold');
        }
      }
    });
  },

  getPatientsSheet: function() {
    var ss = this.getSpreadsheet();
    var sheet = ss.getSheetByName('Patients');
    if (!sheet) {
      sheet = ss.insertSheet('Patients');
      sheet.appendRow([
        'patient_id', 'full_name', 'mobile', 'date_of_birth', 'gender',
        'blood_group', 'email', 'address', 'emergency_contact',
        'emergency_contact_name', 'status', 'created_at', 'updated_at', 'drive_folder_id'
      ]);
      sheet.getRange(1, 1, 1, 14).setFontWeight('bold');
    }
    return sheet;
  },

  generateNextPatientId: function(sheet) {
    var lock = LockService.getScriptLock();
    try {
      lock.waitLock(10000); // 10s wait lock for concurrency protection
      var year = new Date().getFullYear();
      var prefix = 'PAT-' + year + '-';
      var lastRow = sheet.getLastRow();
      
      if (lastRow <= 1) {
        return prefix + '000001';
      }

      var ids = sheet.getRange(2, 1, lastRow - 1, 1).getValues();
      var maxSeq = 0;
      
      for (var i = 0; i < ids.length; i++) {
        var idStr = ids[i][0].toString();
        if (idStr.indexOf(prefix) === 0) {
          var seqPart = idStr.substring(prefix.length);
          var seqNum = parseInt(seqPart, 10);
          if (!isNaN(seqNum) && seqNum > maxSeq) {
            maxSeq = seqNum;
          }
        }
      }

      var nextSeq = maxSeq + 1;
      var padded = ('00000' + nextSeq).slice(-6);
      return prefix + padded;
    } finally {
      lock.releaseLock();
    }
  }
};
