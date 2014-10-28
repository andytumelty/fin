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
      //console.debug(index)
      id = ui.item.data("id");
      
      before = $(this).children().get(index - 1);
      after = $(this).children().get(index + 1);

      if(index - 1 < 0) {
        new_sort = parseFloat($(after).data("sort")) + 1;
      }
      else if(after === undefined) {
        new_sort = parseFloat($(before).data("sort")) - 1;
      }
      else {
        new_sort = (parseFloat($(before).data("sort")) + parseFloat($(after).data("sort")))/2;
      }

      $(ui.item).data("sort", new_sort);

      $.ajax({
        type: "POST",
        url: "/transactions/" + id,
        data: {
          transaction: {
            id: id,
            sort: new_sort
          },
          _method: 'put'
        },
        dataType: "json",
        success: function(xhr){
          //console.debug(xhr.responseText);
          //success = $.parseJSON(xhr.responseText);
          // TODO tie up with data refresh
        },
        error: function(xhr){
          //console.debug(xhr.responseText);
          //errors = $.parseJSON(xhr.responseText);
          // TODO do something with errors
        }
      });

      $(".transaction").slice(0, index + 1).each(function(index){
        id = $(this).data("id");
        //console.debug($("#sortable:nth-child("+ index +")"));
        $.ajax({
          type: "GET",
          url: "/transactions/" + id,
          data: { },
          dataType: "json",
          success: function(data){
            //console.debug(this);
            //$(".transactionstd.balance_amount").html(data['balance']);
          },
          error: function(data){
            console.debug(xhr);
            //errors = $.parseJSON(xhr.responseText);
            // TODO do something with errors
          }
        });
      });
    }
  });
});