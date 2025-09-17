<!--	This is getting executing on click of submit and validate button -->
function fnValidateData() {
		if (!fnCheckMandatoryFields())
		{
			return false;
		}
		return true;
}

function solIdValidate(){
		var objForm = document.forms[0];
		var solId = objForm.solId.value;
	        var inputNameValues = "solId|"+objForm.solId.value;
        	var outputNames      = "";
        	var scrName         = "cbpier_solId_val.scr";
		var retVal = appFnExecuteScript(inputNameValues,outputNames,scrName,false);
		if (retVal != "")
		{
			var token   = retVal.split("|");
			alert(token[0]);
		}
}

function schmCodeValidate(){
                var objForm = document.forms[0];
                var schmCode = objForm.schmCode.value;
                var inputNameValues = "schmCode|"+objForm.schmCode.value;
                var outputNames      = "";
                var scrName         = "cbpier_schemeCode_val.scr";
                var retVal = appFnExecuteScript(inputNameValues,outputNames,scrName,false);
                if (retVal != "")
                {
                        var token   = retVal.split("|");
                        alert(token[0]);
                }
}


/*function isMonthEndDate() {
    // Convert input strings to Date objects
   var input = document.forms[0].asOnDate_ui.value;	 
   var bod = BODDate;
   
       // Check if date is valid
    if (isNaN(input.getTime())) {
            alert("Invalid date format");
	    return false;	
        };
    }
 
    // Check if input date is before BOD date
    if (input >= bod) {
        alert("Input date must be before BOD date");
        return false;
    }
    
    // Get the last day of input's month
    var lastDayOfMonth = new Date(input.getFullYear(), input.getMonth() + 1, 0);
    
    // Check if input date is the last day of its month
    if (input.getDate() !== lastDayOfMonth.getDate()) {
        alert("Input date must be the last day of the month");
        return false;
    }
    
    return true;
}*/

function isMonthEndDate() {
	var lastValidated = "";  // store last checked value
    var objForm = document.forms[0];
    var bodDate = BODDate;
    var dateStr = objForm.asOnDate_ui.value.trim();

    // Skip if value did not change (prevents duplicate alerts)
    if (dateStr === lastValidated) {
        return true;
    }

    if (dateStr === "") {
        alert("Enter month end last date");
        objForm.asOnDate_ui.focus();
        return false;
    }

    var enteredDate = "";

    // Normalize input → always dd-mm-yyyy
    if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
        var parts = dateStr.split("-");
        enteredDate = parts[2] + "-" + parts[1] + "-" + parts[0];
    }
    else if (/^\d{2}-\d{2}-\d{4}$/.test(dateStr)) {
        enteredDate = dateStr;
    }
    else {
        alert("Invalid date format. Use dd-mm-yyyy");
        objForm.asOnDate_ui.focus();
        return false;
    }

    // Convert to comparable format
    function toComparable(d) {
        var p = d.split("-");
        return p[2] + p[1] + p[0];
    }

     // Future date check
    if (toComparable(enteredDate) > toComparable(bodDate)) {
        alert("Do not enter future date");
        objForm.asOnDate_ui.value = "";
        objForm.asOnDate_ui.focus();
        return false;
    }

    // Month end check
    var parts = enteredDate.split("-");
    var day = parseInt(parts[0], 10);
    var month = parseInt(parts[1], 10);
    var year = parseInt(parts[2], 10);

    var daysInMonth = new Date(year, month, 0).getDate();
    if (day !== daysInMonth) {
        alert("Date must be the month-end last date");
        objForm.asOnDate_ui.value = "";
        objForm.asOnDate_ui.focus();
        return false;
    }

    // Success → remember last validated value
    lastValidated = dateStr;
    return true;
}

