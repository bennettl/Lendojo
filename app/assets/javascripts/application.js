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

    	initRatings(); // Initalize raty for reviewsList

    	/************************** AJAX SORTABLE HEADER (INDEX PAGES) **************************/
    	
    	// If .sortable-header exists
    	if ($('.sortable-header').length > 0){
    		// When the sortable-links are clicked, upate the hidden fields with the appropriate values and subit AJAX request to reload form
			$('.sortable-header').on('click', '.sortable-link', function(){
				var column_name 	= $(this).data('column-name'); 
				var direction 		= $(this).data('direction') == 'asc' ? 'desc' : 'asc'; // toggled direction

				// Update hidden fields with the column name and direction
				$('input#sort_name[type="hidden"]').val(column_name);
				$('input#sort_direction[type="hidden"]').val(direction);

				// Make sure everything is decending
				$('.sortable-link .caret').removeClass('asc');
				$('.sortable-link .caret').data('direction', 'desc');

				// Update the toggled data-direction attribute
				$(this).data('direction', direction);
				// then add the ascending class to the sortablelink
				if (direction == 'asc'){
					$(this).find('.caret').addClass('asc');
				}

				// Submit an get AJAX request with the forms paramters
				var form = $(this).parents("form");
				$.get(form.attr('action'), form.serialize(), null, "script");

				return false;
			});
    	}

    	// If .header-dropdown-checkbox exists
    	if ($('.header-dropdown-checkbox').length > 0){
    		// When the dropdown is hidden, submit an get AJAX request with the forms paramters
			$('.header-dropdown-checkbox').on('hide.bs.dropdown', function(){
				var form = $('#reportIndexForm');
				$.get(form.attr('action'), form.serialize(), null, "script");
			});
    	}
    	
    	// AJAX for pagination links
		$('.box').on('click', '.pagination a', function(){
			$.get($(this).attr('href'), null, null, "script");
			return false;
		});

    	/************************** DROPDOWN **************************/
		// Dropdown menus with .dropdown.hover class will be open upon hover event
		$('.dropdown.hover').hover(function() {
			$(this).addClass('open');
		}, function() {
			/* Stuff to do when the mouse leaves the element */
			$(this).removeClass('open');
		});

		// Prevents clicking on input from hiding dropdown menu
		$('.dropdown').on('click','input, select', function (e) {
			e.stopPropagation();
		});
		
    	/************************** TOOLTIP **************************/
    	// Activate tooltip for all .tooltip_target, set container to body to prevent divs from mmoving around if tooltip is appended to it
    	$('body').tooltip({
    		container: 'body',
    		selector: '.tooltip_target'
    	});
    	// Whenever a link is click, remove tooltip
    	$(document).on('click', 'a', function(){
	    	$('.tooltip').remove();
    	});
	}

}());

// Initalize raty for reviewsList
function initRatings(){
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


