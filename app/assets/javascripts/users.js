// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

//= require bootstrap
//= require moment
//= require bootstrap-datetimepicker
//= require date.format

// Date: date.format formats a unix timestamp
// http://blog.stevenlevithan.com/archives/date-time-format

$(document).ready(function(){
	ccInit();
	checkList();
});

// Handles the JS for users/checklist
function checkList(){

	// Green notifciation box for checklist updates made, intially hide it
	$('.checkList .alert.alert-success').hide();

	/********************************** SCHEDULE_DATE OPTION **********************************/
	
	var update_schedule_form = $("form.update_schedule_date_form");
	var schedule_option 	 = $('form.update_schedule_date_form .schedule'); // calender glyphicon

    schedule_option.datetimepicker(); // datetimepicker initialized

    // When the DateTimePicker changes, .schedule_date changes
    schedule_option.on("dp.change", function(e){
    	// Grab the datetime, format it, and update the .schedule_date cell
		var schedule_date_div 	=  $(this).parents("tr.check").find(".schedule_date")
    	var unix_timestamp 		= e.date;
        var date 				= new Date(unix_timestamp);
        var formatted_date 		= dateFormat(date, "mmmm dS, yyyy, dddd @ h:MM TT");
        
        schedule_date_div.html(formatted_date);
    });

    // When DateTimePicker hides, notified the user and submit the form
	schedule_option.on("dp.hide", function(e){
    	// Prepare the information for notification
    	var success_box			= $(this).parents(".checkList").find(".alert.alert-success"); // find the lender's success box
    	var unix_timestamp 		= e.date;
        var date 				= new Date(unix_timestamp);
        var formatted_date 		= dateFormat(date, "dddd, mmmm d, yyyy | h:MM TT");

        // Notified user via success_box
        success_box.show();
    	success_box.html('Schedule Date Updated to ' + formatted_date);

    	// Set the hidden field to date formatted for active record
    	var ar_formatted_date 	= dateFormat(date, "yyyy-mm-dd HH:MM:ss");
    	$('input[name="user_service[scheduled_date]"]').val(ar_formatted_date);

    	// Submit the form to update the user_service
    	update_schedule_form.submit();
    });

	/********************************** SCHEDULE_DATE OPTION **********************************/

	/********************************** CHARGE OPTION **********************************/
	var charge_form = $('form.update_charge_form');
	charge_form.on('click', '.charge', function(){
    	// Prepare the information for notification
		var success_box			= $(this).parents(".checkList").find(".alert.alert-success"); // find the lendee's success box
		var row 				= $(this).parents("tr.check");
    	var name 				= row.find(".lendee").text().split(" ")[0].trim();
    	var amount 				= row.find(".price").text().trim();

		 // Notified user via success_box
		success_box.show();
    	success_box.html('Respect. ' + name + " has paid you " + amount + "!");

    	// Change text from to "Completed"
    	var status = row.find(".status");
    	status.html("Completed");

		// Submit form to update the user_service and empty all the options
		var options_checklist = row.find(".options_checklist");
		charge_form.submit();
		options_checklist.html("");

	});
	
	/********************************** CHARGE OPTION **********************************/

	/********************************** CONFIRM OPTION **********************************/
	var confirm_form = $('form.update_confirmation_form');

	// When confirm option is clicked
	confirm_form.on('click', '.confirm', function(){
    	// Prepare the information for notification
    	var success_box			= $(this).parents(".checkList").find(".alert.alert-success"); // find the lendee's success box
		var row 				= $(this).parents("tr.check");
    	var day 				= row.find(".schedule_date").text().split(",")[0].trim();
    	var name 				= row.find(".lender").text().split(" ")[0].trim();

        // Notified user via success_box
		success_box.show();
    	success_box.html('Service Confirmed. ' + name + " will see you on " + day + "!");
    	
    	// Change text from "Please Confirm" to "Confirmed"
    	var status = row.find(".status");
    	var nextText = status.html().replace("Please Confirm", "Confirmed");
    	status.html(nextText);
    	
    	// Submit form to update the user_service and hide it
		confirm_form.submit();
		confirm_form.hide();
	});

	/********************************** CONFIRM OPTION **********************************/

	/********************************** REMOVE OPTION **********************************/

	// Use for shared/_options partial
	// When user clicks <a> on #options, if a parent form exist, submit it
	$('.options_checklist').on('click','a.option', function(){ 
		var form 			= $(this).parents("form");
		var checkListRow 	= $(this).parents("tr.check");

		// If the form is in a checklist, user decides to remove it, hide the row.
		if ($(this).hasClass("uncheck") && checkListRow.length != 0){
			checkListRow.hide();
		}

		// If for exists, submit it and return false
		if (form.length != 0){
			form.submit();
			return false;
		}
	});		
	/********************************** REMOVE OPTION **********************************/
}

// Handle credit card 
function ccInit(){

	// Set stripe public key
	var public_key = $('meta[name="strip_key"]').attr('content');
	Stripe.setPublishableKey(public_key);

	// If #showUpdateCardForm link exist, hide the update_card form
	if ($('#showUpdateCardForm').length > 0){
		$('#update_card').hide();
	}

	// Toggles 'Change'/'Hide' text of #showUpdateCardForm and display of update_card form
	$('#showUpdateCardForm').on('click', function(){
		// Toggle #showUpdateCardForm text
		var text = ($(this).text() == 'Change') ? 'Hide' : 'Change';
		$(this).text(text);
		// Toglle #update_card form
		$('#update_card').toggle();
		return false;
	});

	// Create a stripe token when donation form submits
	$('#update_card').on('submit', function(){

		// Setting up credit card data object
		var number 		= $('input[name="number"]').val();
		var cvc 		= $('input[name="cvc"]').val();
		var exp_month 	= $('#exp_month').val();
		var exp_year 	= $('#exp_year').val();
		var cardData 	= {number: number,
						    cvc: cvc,
						    exp_month: exp_month,
						    exp_year: exp_year
							};

		Stripe.card.createToken(cardData, stripeResponseHandler);

		return false;
	});
}

// Append toke to donation form and resubmit
function stripeResponseHandler(status, response) {
	if (response.error) {
        // show the errors on the form
        $('#ccSection .error').text(response.error.message);
    } else {
        var form = $('#update_card');
        // token contains id, last4, and card type
        var token = response['id'];
        console.log(token);
        // insert the token into the form so it gets submitted to the server and submit
        form.append("<input type='hidden' name='stripeToken' value='" + token + "'/>");
        form.get(0).submit();
    }
}