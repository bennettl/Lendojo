// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

//= require bootstrap

jQuery(document).ready(function($) {
    initFilterSystem();
});

jQuery(document).on('page:change, page:load', initFilterSystem);

/********************************** FILTER SYSTEM **********************************/
function initFilterSystem(){

	/******* INITIALIZATION *******/

	// Container for entire filter system
	var filter_container = $('#filter-container');

	// Initalize g_filter_data (global)
	var g_filter_data			= {};
	g_filter_data.locations		= []; // Los Angeles, Silicon Valley
	g_filter_data.prices		= []; // $, $$, $$$, $$$$
	g_filter_data.belts			= []; // white, green, blue, red, black
	g_filter_data.keywords		= []; // Babysitting

	// Set filter data and .current_filters to the first filter (if user has one)
	var default_filter = $(".my-filter-row.body").eq(0);
	if (default_filter.length > 0){
		var l_filter_data = default_filter.data().filter_data;
		setGlobalFilterData(l_filter_data);
	}
	/******* FILTERS *******/

	// A new my-filter is saved. Will be created or updated (base on title)
	filter_container.on('click', '.save-current-filters', function(e){
		var title = filter_container.find('input[name="filter_title"]').val();
		
		// Empty filter title input
		$('input[name="filter_title"]').val("");

		// Make an asynchronous call to create filter
		$.ajax({
			type: "POST",
			url: "/filters",
			data: {'title':  title ,'filter_data': g_filter_data},
			dataType:'json'
		}).done(function(response){
			// Create a new HTML for my_filter and append it to .my-filters-dropdown
			console.log(response);
			var my_filter 		= response.my_filter;
			var my_filter_HTML 	= $('<li data-filter_id="' + my_filter.id + '" data-filter_data="' + g_filter_data + ' "class="my-filter-row body"><div><span class="my-filter-name">' + my_filter.title + '</span><span class="my-filter-alert"><input type="checkbox" checked="checked" name="filter-alert"></span><span class="my-filter-remove glyphicon glyphicon-remove"></span></div></li>');
			filter_container.find('.my-filters-dropdown').append(my_filter_HTML);
			console.log(my_filter.data);
		});

	});

	// Update alert for my-filter
	filter_container.on('change', 'input[name="filter-alert"]', function(){		
		var myFilter 		= $(this).parents('.my-filter-row');
		var filter_id 		= myFilter.data().filter_id;
		var l_filter_data 	= { 'alert': $(this).is(":checked") };

		// Make a asynchronous call to update filter (speficially alert)
		$.ajax({
			type: "PATCH",
			url: "/filters/" + filter_id,
			data: {'filter_data' : l_filter_data},
			dataType:'json'
		}).done(function(data){
			// console.log(msg);
		});
	});

	// Remove my-filter
	filter_container.on('click', '.my-filter-remove', function(e){
		var myFilter 	= $(this).parents('.my-filter-row');
		var filter_id 	= myFilter.data().filter_id;

		// Remove the HTML .my-filter-row
		myFilter.remove();

		// Make an asynchronous call to delete filter
		$.ajax({
			type: "DELETE",
			url: "/filters/" + filter_id,
			data: '',
			dataType:'script'
		}).done(function(msg){
			// console.log(msg);
		});
	});

	// Custom filter is selected
	filter_container.on('click', '.my-filter-row', function(){
		var l_filter_data 	= $(this).data().filter_data;
		setGlobalFilterData(l_filter_data);		
	});

	/******* KEYWORD BOX *******/
	// When .current-filters (top filter box) is clicked, focus on the keyword-input-box
	filter_container.on('click', '.filter-box', function(e){
		filter_container.find(".keyword-box").slideDown(300);
		$('input.keyword-input').focus();
	});

	// When user hits enter, submit the text value as a new keyword filter-item
	filter_container.on('keydown', 'input[name="keywords"], input[name="locations"]', function(e){
		var value = $(this).val();
		var key = $(this).attr('name'); // locations, keywords

		// If the user pressed enter
		if (e.keyCode == 13){
			// Empty input
			$(this).val("");
			// Add filter to g_filter_data and DOM
			addFilterItem(key, value);
			// Hide the dropdown menu if there is one
			$(this).parents("li.dimension.dropdown.open").removeClass("open");
	    }
	});

	// On the keyword input is on blur, slide up the keyword-box
	filter_container.on('blur', 'input.keyword-input', function(){
		$(this).parents(".keyword-box").slideUp(300);
	});

	/******* FILTER ITEMS *******/

	// Adding a filter item
	filter_container.on('click', '.filter-item a', function(){
		var dropdown 	= $(this).parents(".dropdown");
		var filter 		= $(this).parents(".filter-item");
		var key 		= filter.data().key;
		var value 		= filter.data().value; 

		// Add filter (both to g_filter_data object and .current-filters div)
		addFilterItem(key, value);
		// Hide the dropdown menu
		dropdown.removeClass('open');
		console.log(g_filter_data);

		return false;
	});

	// Removing a filter item
	filter_container.on('click','.filter-remove', function(){
		var filter 	= $(this).parents(".filter");
		var key 	= filter.data().key;
		var value 	= filter.data().value;

		// Remove the value from g_filter_data
		g_filter_data[key].remove(value);
		// Refresh the index page with new g_filter_data information
		refreshIndex();
		// Remove the filter's HTML
		filter.remove();
		e.stopPropagation();
		console.log(g_filter_data);
	});

	
	/******* HELPER FUNCTIONS *******/

	// Prevents clicking on input from hiding dropdown menu
	$('.dropdown').on('click','input', function (e) {
		e.stopPropagation();
	});

	// Sets the current 'g_filter_data' object to 'l_filter_data', changes the HTML accordingly, and refreshes the index/list of services
	function setGlobalFilterData(l_filter_data){
		// Container for current filters
		var current_filters 	= filter_container.find(".current-filters");

		// Set global filter_data to l_filter_data
		g_filter_data = l_filter_data;

		// Empty current filters
		current_filters.html('');

		// Generate new .filter HTML and append them to current_filter
		for (var dimensionName in g_filter_data) { // dimensionName: locations, belts, prices, etc. 
			var dimensionArray = g_filter_data[dimensionName];
			
			for (var i = 0; i < dimensionArray.length; i++){ // i: 0, 1, 2
				var dimensionValue = dimensionArray[i] // dimensionValue: Los Angeles, USC, etc.
				// Create the HTML
				var filter_HTML = $('<div class="filter" data-key="' + dimensionName +'" data-value="' + dimensionValue + '">' + dimensionValue + '<span class="filter-remove glyphicon glyphicon-remove"></span></div>');
				current_filters.append(filter_HTML);
			}
		}
		// Refrehes the services list with the current 'g_filter_data' object
		refreshIndex();
		console.log(g_filter_data);
	}

	// Calls the server for services index base on the current 'g_filter_data' object and refreshes the list
	function refreshIndex(){
		// Make an asynchronous call to get a list of services
		$.ajax({
			type: "GET",
			url: "/services",
			data: {'filter_data': g_filter_data},
			dataType:'script'
		}).done(function(msg){
			// console.log(msg);
		});
	}

	// Add filter item data (key, value) to g_filter_data and appends new div to .current-filters
	function addFilterItem(key, value){

		// Make sure g_filter_data has key dimension
		if (g_filter_data[key] ===  undefined){
			g_filter_data[key] = [];
		}

		// Only add if it doesn't exist
		if (g_filter_data[key].indexOf(value) != -1){
			return false;
		}

		// Push the value to the appropriate g_filter_data[key] array
		g_filter_data[key].push(value);
		// Refresh the index page with new g_filter_datat information
		refreshIndex();

		// Create the HTML markup
		var filter_html = $('<div class="filter" data-key="' + key + '" data-value="' + value + '">' + value + '<span class="filter-remove glyphicon glyphicon-remove"></span></div>');

		// Place HTML after the last current filter with the same key so filters are grouped logically
		var last_filter = filter_container.find('.current-filters .filter[data-key="' + key + '"]').last();
		
		// If there are no filter-items with the same dimension to insert after, append to .current-filters
		if  (last_filter.length == 0){
			filter_html.appendTo(filter_container.find('.current-filters'));
		} else{
			filter_html.insertAfter(last_filter);			
		}

		console.log(last_filter);
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