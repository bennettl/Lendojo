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

    	// Fade out alters when they are visible
    	if ($(".alert").css("display") == "block"){
    		setTimeout(function(){
				$(".alert").fadeOut(500);
    		}, 5000);
    	}

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
    	
    	// AJAX for pagination
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

/************************** AUTOCOMPLETE SYSTEM (SINGLETON) **************************/

// How to use
// 1. Place the following HTML in body: <div id="tag-container"></div> will hold the .tag-box
// 3. Input must have the class '.tag-input', name attribute will be the category of the tag

var AutoComplete = {

   	tag_data: {}, // Initalize (global) tag_data
	
	/******* INITIALIZATION *******/

    init: function(){

    	// If autcomplete input exists
		if ($('input.tag-input').length == 0){
			return;
		}

        var that = this; // Store reference here for callback

        // Create the HTML to hold autocomplete suggestsions
        $('<ul id="tag-list"></ul>').appendTo('body');

    	// Set filter data and .current_filters_tags to the first filter (if user has one)
		var default_filter = $(".my-filter-row.body").eq(0);
		if (default_filter.length > 0){
			var l_filter_data = default_filter.data().tag_data;
			this.setTagData(l_filter_data);
			this.refreshServiceIndex();
		}

		// Autocomplete for input.tag-input. Reloads tagList in real time every time the user types
	    $('.container').on('keyup', 'input.tag-input', function(e) {
	    	// Key up, down, enter
			switch (e.keyCode){
				case 38: // up
					var prev 	= $(".tag-item.active").removeClass('active').prev();
					prev 		= (prev.length > 0) ? prev : $(".tag-item").last(); // if there's no previous, set prev to last
					prev.addClass('active');
					break;
				case 40: // down
					var next 	= $(".tag-item.active").removeClass('active').next();
					next 		= (next.length > 0) ? next : $(".tag-item").first(); // if there's no next, set prev to first
					next.addClass('active');
					break;
				case 13: //enter
					// Either get the category/name from .tag-item active or from the input
					var category 	= ($(".tag-item.active").length > 0) ? $(".tag-item.active").data('category') : $(this).data('category');
					var name 		= ($(".tag-item.active").length > 0) ? $(".tag-item.active").data('name') : $(this).val();
					that.addTag($(this), category, name); // add tag
					break;
			}
			if (e.keyCode == 38 || e.keyCode == 40 || e.keyCode == 13){
				e.stopPropagation();
				return;
			}

			// Autocomplete

	    	// Append tag_list to parent
	    	$(this).parent().append($("#tag-list"));

	    	// Get CSS properties of input
	    	var top 		= parseInt($(this).css('margin-top')) + $(this).position().top + parseInt($(this).css('height')) + 2;  // top + margin-top
	    	var left 		= $(this).position().left + + parseInt($(this).css('margin-left')); // left + margin-left
	    	var width 		= $(this).css('width');

	    	// GET request to /tags
	        var path 		= '/tags/';
	        var category 	= $(this).data('category'); //location
	        var name 		= $(this).val(); // san fran...
	        var info = { 'tag[category]':  category, 'tag[name]': name };
	        $.get(path, info, function(){
				// Show/hide #tag-List depending if items are inside
				if ($("#tag-list .tag-item").length == 0){
					$("#tag-list").hide();
				} else{
					// Set tag_list css properties and the first tag-list item as active class
			    	$("#tag-list").css( {top: top, left: left, width: width} );
			    	$("#tag-list .tag-item").eq(0).addClass('active');	
					$("#tag-list").show();
				}
	        }, "script");
	    });

		// Adding a tag item on click
		$('.container').on('click', '.tag-item', function(){		
			var category 	= $(this).data('category');
			var name 		= $(this).data('name');
			// Add filter tag (both to tag_data object and .current-filters div)
			that.addTag($(this), category, name);
			return false;
		});

		// // Removing a tag item
		$('#tag-container').on('click','.tag-box .tag-remove', function(e){
			// Find the parent tag_box's category and name
			var category 	= $(this).parents(".tag-box").data('category');
			var name 		= $(this).parents(".tag-box").data('name');
			that.removeTag(category, name);
			e.stopPropagation(); // prevent keyword box from popping up
		});

		return this;
    },
    // Add tag data (category, name) to tag_data and appends new div to #tagContainer
	addTag: function(tag_input, category, name){

		var tag_container = $("#tag-container"); // container that contain all tags
				
		tag_input.val(""); // empty input

		// Hide the tag-dropdown, need a class because Bootstrap dropdowns are tag dropdowns
		$(".tag-dropdown.open").removeClass("open");

		// Make sure tag_data has category dimension
		if (this.tag_data[category] ===  undefined){
			this.tag_data[category] = [];
		}

		// Only add if it doesn't exist
		if (this.tag_data[category].indexOf(name) != -1){
			return false;
		}

		// Push the name to the appropriate tag_data[category] array
		this.tag_data[category].push(name);


		// Create the HTML
		var tag_container  	= $("#tag-container");
		var tag_box 		= $('<div class="tag-box" data-category="' + category + '" data-name="' + name + '">' + name + '<span class="tag-remove glyphicon glyphicon-remove"></span></div>');

		// Place HTML after the last tag-box with the same category so tags are grouped logically
		var last_filter 			=  tag_container.find('.tag-box[data-category="' + category + '"]').last();

		// If there are no filter-items with the same dimension to insert after, append to .current-filters
		if  (last_filter.length == 0){
			tag_box.appendTo(tag_container);
		} else{
			tag_box.insertAfter(last_filter);			
		}
		console.log(this.tag_data);
		this.refreshServiceIndex();
	},
	// Remove tag data (category, name) to tag_data and appends new div to #tagContainer
	removeTag: function(category, name){
		// Remove the tag_box HTML
		$('.tag-box[data-category="' + category + '"][data-name="' + name + '"]').remove();
		// Remove the value from tag_data
		this.tag_data[category].remove(name);
		console.log(this.tag_data);
		this.refreshServiceIndex();
	},
	// Sets the current 'tag_data' (global) object to 'l_tag_data' (local), changes the HTML accordingly, and refreshes the index/list of services
	setTagData: function(l_tag_data){
		// Container for current filters
		var tag_container 	= $('#tag-container');

		// Set global filter_data to l_filter_data
		this.tag_data = l_tag_data;

		// Empty current filters
		tag_container.html('');

		// Generate new .filter HTML and append them to current_filter
		for (var category in this.tag_data) { // category: locations, belts, prices, etc. 
			var categoryArr = this.tag_data[category];
			
			for (var i = 0; i < categoryArr.length; i++){ // i: 0, 1, 2
				var name = categoryArr[i] // name: Los Angeles, USC, etc.
				// Create the HTML
				var tag_HTML = $('<div class="tag-box" data-category="' + category +'" data-name="' + name + '">' + name + '<span class="tag-remove glyphicon glyphicon-remove"></span></div>');
				tag_container.append(tag_HTML);
			}
		}
		// Refrehes the services list with the current 'tag_data' object
		console.log(this.tag_data);
		this.refreshServiceIndex();
	}, 

	// Calls the server for services index base on the current 'tag_data' object and refreshes the list
	refreshServiceIndex: function (){
		// Make an asynchronous call to get a list of services
		$.get('/services', { 'tag_data': this.tag_data }, null, "script");
	}
};

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


/********************************** HELPER FUNCTIONS **********************************/

// Remove an item from an array
Array.prototype.remove = function() {
    var what, a = arguments, L = a.length, ax;
    while (L && this.length) {
        what = a[--L];
        while ((ax = this.indexOf(what)) !== -1) {
            this.splice(ax, 1);
        }
    }
    return this;
};


