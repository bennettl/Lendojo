// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

//= require bootstrap

jQuery(document).ready(function($) {
    initService();
});

jQuery(document).on('page:change, page:load', initService);

function initService(){
	initFilterSystem();
}

/********************************** FILTER SYSTEM **********************************/
function initFilterSystem(){

	// If autcomplete input exists
	if ($('input.tag-input').length == 0){
		return;
	}

	 AutoComplete.init(); // initalize autocomplete
	

	/******* INITIALIZATION *******/

	// Container for entire filter system
	var filter_container = $('#filter-container');

	/******* FILTERS *******/

	// A new my-filter is saved. Will be created or updated (base on title)
	filter_container.on('click', '.save-current-filters', function(e){
		var title = filter_container.find('input[name="filter_title"]').val();
	

		// Empty filter title input
		$('input[name="filter_title"]').val("");

		// Make an asynchronous call to create filter
        $.post('/filters', {'title':  title ,'filter_data': Autocomplete.g_tag_data}, function(response){
          
           	// Create a new HTML for my_filter and append it to .my-filters-dropdown
			console.log(response);
			var my_filter 		= response.my_filter;
			var my_filter_HTML 	= $('<li data-filter_id="' + my_filter.id + '" data-tag_data="' + g_tag_data + ' "class="my-filter-row body"><div><span class="my-filter-name">' + my_filter.title + '</span><span class="my-filter-alert"><input type="checkbox" checked="checked" name="filter-alert"></span><span class="my-filter-remove glyphicon glyphicon-remove"></span></div></li>');
			filter_container.find('.my-filters-dropdown').append(my_filter_HTML);
			console.log(my_filter.data);
        }, 'json');
	});

	// Update alert for my-filter
	filter_container.on('change', 'input[name="filter-alert"]', function(){		
		var myFilter 		= $(this).parents('.my-filter-row');
		var filter_id 		= myFilter.data().filter_id;
		var data 			= { 'alert': $(this).is(":checked") };

		// Make a asynchronous call to update filter (speficially alert)
		$.ajax({
			type: "PATCH",
			url: "/filters/" + filter_id,
			data: {'filter_data' : data},
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
		var tag_data 	= $(this).data().tag_data;
		AutoComplete.setGlobalTagData(tag_data);		
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