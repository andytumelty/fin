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
//= require_tree .
//= require jquery.ui.datepicker
//= require jquery.ui.datepicker-en-GB
//= require jquery.ui.sortable

$(function(){ 
  $('.datepicker').datepicker();

  $("#transaction_filter_row").hide();
  $("#transaction_filter_row_toggle").click(function() {
    $("#transaction_filter_row").toggle();
  });

  $("#sortable").sortable({
    update: function(event, ui){
      index = ui.item.index();
      console.debug( $(this) );
      console.debug( index );
      console.debug( $(this).children().get(index - 1) );
      console.debug( $(this).children().get(index + 1) );
    }
  });
});