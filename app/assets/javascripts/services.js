// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

//= require bootstrap

jQuery(document).ready(function($) {
    initService();
});

jQuery(document).on('page:change, page:load', initService);

function initService(){
	var a = AutoComplete.init(); // initalize autocomplete system
	Filter.init(a); // intialize filter system with autocomplete object
}

/********************************** FILTER SYSTEM (SINGLETON) **********************************/

var Filter = {

	/******* INITIALIZATION *******/
	autocomplete: {},
	init: function (autocomplete){


		// Container for entire filter system
		var filter_container = $('#filter-container');

		// If filter-container exists, continue
		if (filter_container.length == 0){
			return;
		}

	    var that 				= this; // Store reference here for callback
		this.autocomplete 		= autocomplete; // Will reference this tag_data from now on

		// Save a new filter or update an existing one base on it's name
		filter_container.on('click', '.save-current-filters', function(e){
			// Get the filter title's value and empty it
			var title = filter_container.find('input[name="filter_title"]').val();
			$('input[name="filter_title"]').val("");

			var data = {'title':  title ,'filter_data': that.autocomplete.tag_data}

			console.log('data post to filters', data);
			// Create a filter
	        $.post('/filters', data , function(response){	          
	           	// Create a new HTML for my_filter and append it to .my-filters-dropdown
				var my_filter 		= response.my_filter;
				var my_filter_HTML 	= $('<li data-filter_id="' + my_filter.id + '" data-tag_data="' + that.autocomplete.tag_data + ' "class="my-filter-row body"><div><span class="my-filter-name">' + my_filter.title + '</span><span class="my-filter-alert"><input type="checkbox" checked="checked" name="filter-alert"></span><span class="my-filter-remove glyphicon glyphicon-remove"></span></div></li>');
				filter_container.find('.my-filters-dropdown').append(my_filter_HTML);
				console.log(my_filter.data);
	        }, 'json');
		});

		// Update alert for my-filter
		filter_container.on('change', 'input[name="filter-alert"]', function(){		
			// Grab the filter id and alert checkbox value
			var myFilter 		= $(this).parents('.my-filter-row');
			var filter_id 		= myFilter.data().filter_id;
			var alert 			= { 'alert': $(this).is(":checked") };

			// Make a asynchronous call to update filter (speficially alert)
			$.ajax({ type: "PATCH", url: "/filters/" + filter_id, data: {'filter_data' : alert}, dataType:'json' }).done(function(data){
				// console.log(msg);
			});
		});

		// Remove my-filter
		filter_container.on('click', '.my-filter-remove', function(e){
			// Grab the filter id and remove it
			var myFilter 	= $(this).parents('.my-filter-row');
			var filter_id 	= myFilter.data().filter_id;

			// Remove the HTML
			myFilter.remove();

			// Make an asynchronous call to delete filter
			$.ajax({ type: "DELETE", url: "/filters/" + filter_id, data: '', dataType:'script' }).done(function(msg){
				// console.log(msg);
			});
		});

		// Custom filter is selected
		filter_container.on('click', '.my-filter-row', function(){
			var tag_data 	= $(this).data().tag_data;
			that.autocomplete.setTagData(tag_data);		
		});

		/******* KEYWORD BOX *******/
		// When .current-filters (top filter box) is clicked, focus on the keyword-input-box
		filter_container.on('click', '.filter-box', function(e){
			filter_container.find(".keyword-box").slideDown(300);
			$('input.keyword-input').focus();
			console.log('hey');
		});


		// On the keyword input is on blur, slide up the keyword-box
		filter_container.on('blur', 'input.keyword-input', function(){
			$(this).parents(".keyword-box").slideUp(300);
		});
	}
}	