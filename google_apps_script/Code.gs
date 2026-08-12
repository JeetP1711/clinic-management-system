function doPost(e) {
  try {
    var contents = JSON.parse(e.postData.contents);
    var action = contents.action;
    
    if (action === 'createPatient') {
      return handleCreatePatient(contents);
    }
    
    return ResponseHelper.error('Invalid POST action: ' + action);
  } catch (err) {
    return ResponseHelper.error('Server error: ' + err.toString());
  }
}

function doGet(e) {
  try {
    var params = e.parameter;
    var action = params.action;
    
    if (action === 'getPatients') {
      return handleGetPatients();
    } else if (action === 'getPatient') {
      return handleGetPatient(params.patient_id);
    } else if (action === 'searchPatients') {
      return handleSearchPatients(params.query);
    }
    
    return ResponseHelper.error('Invalid GET action: ' + action);
  } catch (err) {
    return ResponseHelper.error('Server error: ' + err.toString());
  }
}
