// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/


jQuery(document).ready(function($) {
    newRating();
});

jQuery(document).on('page:change, page:load', newRating);

// Handles the JS for new_rating form
function newRating(){
	var new_rating = $('#newRating');
		
	// Continue if it .ratyHTML exists
	if (new_rating.length > 0){
		// Raty jQuery plugin for front-end 5 star widget
		new_rating.find('.raty').raty({
			starOff   	: '/images/raty/star-off-big.png',
			starOn    	: '/images/raty/star-on-big.png',
			hints 		: ['Horrible', "Mediocre", "Okay", "Great", "Awesome!"],
			target 		: "#raty-hint",
			targetKeep 	: true,
			score		: 3,
			click 		: function(score, evt) {
							// Modify the rating[stars] and review stars field
							$('input#rating_stars, input#review_stars').val(score);
						  }
		});

		// When 'submitRating' is click, submit both the rating and review forms
		new_rating.on('click', '#submitRating', function(){
			// Submit the reviews form, this is set to remote
			new_rating.find('form#reviewForm').submit();
			// Submit the ratings form, this is NOT remote, so that ratings - create will redirect user back to checklist
			new_rating.find('form#ratingForm').submit();
			return false;
		});
	}
}
;
