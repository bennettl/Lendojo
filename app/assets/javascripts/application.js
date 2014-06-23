// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery.raty.js
//= require bootstrap

// Remove //= require_tree because we don't want to include all javascript files

(function(){

    jQuery(document).ready(function($) {
        initApp();
    });

    jQuery(document).on('page:change, page:load', initApp);


    function initApp(){

    	/************************** DROPDOWN **************************/
		// Open dropdown menu on hover
		$('.dropdown.hover').hover(function() {
			$(this).addClass('open');
		}, function() {
			/* Stuff to do when the mouse leaves the element */
			$(this).removeClass('open');
		});

    	/************************** TOOLTIP **************************/
    	// Activate tooltip for all .tooltip_target, set container to body to prevent divs from mmoving around if tooltip is appended to it
    	$('.tooltip_target').tooltip({container: 'body'});

    	/************************** OPTIONS **************************/
		// Use for shared/_options partial
		// When user clicks <a> on #options, if a parent form exist, submit it
		$('.options').on('click','a.option', function(){ 
			var form 			= $(this).parents("form");		

			// If for exists, submit it and return false
			if (form.length != 0){
				form.submit();
				return false;
			}
			
		});

		/************************** REVIEW LIST **************************/

		// If .review-list exists, continue
		if ($('.review-list-item, .review-index-item').length > 0){
			// Get the # of stars for each review-list item and use it for the raty function
			$('.review-list-item, .review-index-item').each(function(){
				var ratyHTML 	= $(this).find('.raty');
				var stars 		= ratyHTML.data().stars;

				ratyHTML.raty({
					starHalf   	: '/images/raty/images/star-half.png',
					starOff    	: '/images/raty/images/star-off.png',
					starOn     	: '/images/raty/images/star-on.png',
					hints 		: ['Horrible', "Mediocre", "Okay", "Great", "Awesome!"],
					readOnly	: true, 
					score		: stars
				});	
			});
		}
	}

}());

