// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

//= require bootstrap
$(document).ready(function(){
	initFilterSystem();
});

/********************************** FILTER SYSTEM **********************************/
function initFilterSystem(){

	/******* INITIALIZATIONS *******/

	// Container for entire filter system
	var filter_container = $('#filter-container');

	// Initalize g_filter_data (global)
	var g_filter_data 			= {};
	g_filter_data.locations 	= []; // Los Angeles, Silicon Valley
	g_filter_data.prices 		= []; // $, $$, $$$, $$$$
	g_filter_data.belts 		= []; // white, green, blue, red, black
	g_filter_data.keywords 		= []; // Babysitting
	
	// Set filter data and .current_filters to the first filter if user has one
	var default_filter = $(".my-filter-row.body").eq(0);
	if (default_filter.length > 0){
		var l_filter_data = default_filter.data().filter_data;
		setGlobalFilterData(l_filter_data);
	}

	// Initially populate g_filter_data with filter information grabbed from .current-filters .filter
	$('.current-filters .filter').each(function(){
		var filter	= $(this);
		var key 	= filter.data().key;
		var value 	= filter.data().value;

		// Push the value to the appropriate g_filter_data[key] array
		g_filter_data[key].push(value);
	});

	// Custom filter is selected
	filter_container.on('click', '.my-filter-row', function(){
		var l_filter_data 	= $(this).data().filter_data;
		setGlobalFilterData(l_filter_data);		
	});

save-current-filters

	/******* FILTER ITEMS *******/

	// Adding a filter item
	filter_container.on('click', '.filter-item a', function(){
		var dropdown 	= $(this).parents(".dropdown");
		var filter 		= $(this).parents(".filter-item");
		var key 		= filter.data().key;
		var value 		= filter.data().value; 
		
		// Add filter (both to g_filter_data object and .current-filters div)
		addFilter(key, value);
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
		console.log(g_filter_data);
	});

	
	/******* HELPER FUNCTIONS *******/

	// Prevents clicking on input from hiding dropdown menu
	$('.dropdown input').bind('click', function (e) {
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
				var filter_HTML = $('<div class="filter" data-key="' + dimensionName+ '" data-value="' + dimensionValue + '">' + dimensionValue + '<span class="filter-remove glyphicon glyphicon-remove"></span></div>');
				current_filters.append(filter_HTML);
			}

		}
		// Refrehes the services list with the current 'g_filter_data' object
		refreshIndex();
		console.log(g_filter_data);
	}

	// Calls the server for services index base on the current 'g_filter_data' object and refreshes the list
	function refreshIndex(){
		$.ajax({
			type: "GET",
			url: "/services",
			data: {'filter_data': g_filter_data},
			dataType:'script'
		}).done(function(msg){
			// console.log(msg);
		});
	}

	// Add filter data (key, value) to g_filter_data and appends new div to .current-filters
	function addFilter(key, value){

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
		last_filter 	= last_filter.length == 0 ? filter_container.find('.current-filters .filter').last() : last_filter

		console.log(last_filter);

		filter_html.insertAfter(last_filter);
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