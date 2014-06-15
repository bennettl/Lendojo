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
//= require_tree .

jQuery(document).ready(function($){

	// Use for shared/_options partial
	// When user clicks <a> on #options, if a parent form exist, submit it
	$('#options').on('click','a', function(){ 
		var form = $(this).parents("form");

		// If for exists, submit it and return false
		if (form.length != 0){
			form.submit();
			return false;
		}
		
	});

});

