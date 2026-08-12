var ResponseHelper = {
  success: function(data, message) {
    var output = {
      success: true,
      message: message || 'Success',
      data: data || null
    };
    return ContentService
      .createTextOutput(JSON.stringify(output))
      .setMimeType(ContentService.MimeType.JSON);
  },
  
  error: function(message, code) {
    var output = {
      success: false,
      message: message || 'An unexpected error occurred',
      code: code || 'ERROR'
    };
    return ContentService
      .createTextOutput(JSON.stringify(output))
      .setMimeType(ContentService.MimeType.JSON);
  }
};
