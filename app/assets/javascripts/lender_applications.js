// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

jQuery(document).ready(function($) {
    initLenderApp();
});

jQuery(document).on('page:change, page:load', initLenderApp);

function initLenderApp(){
	AutoComplete.init(); // initalize autocomplete system
}
