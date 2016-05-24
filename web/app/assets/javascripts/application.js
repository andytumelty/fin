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
//= require jquery-ui/datepicker
//= require jquery-ui/datepicker-en-GB
//= require jquery-ui/sortable

$(function(){ 
  $('.datepicker').datepicker();

  $("#transaction_filter_row").hide();
  $("#transaction_filter_row_toggle").click(function() {
    $("#transaction_filter_row").toggle();
  });

  $('form.autopost > select').change(function(){
    category_id = $(this).val();
    url = $(this).parent().attr("action");
    id = url.split("/")[1]
      $.ajax({
        type: "POST",
        url: url,
        data: {
          transaction: {
            id: id,
            category_id: category_id
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
  });

  //$("#sortable").sortable({
  //  start: function(e, ui){
  //    $(this).data('previndex', ui.item.index());
  //  },
  //  update: function(e, ui){
  //    index = ui.item.index();
  //    prev_index = $(this).data('previndex');
  //    $(this).removeAttr('data-previndex');
  //    
  //    //console.debug(prev_index + " -> " + index)
  //    
  //    id = ui.item.data("id");
  //    
  //    before = $(this).children().get(index - 1);
  //    after = $(this).children().get(index + 1);

  //    if(index - 1 < 0) {
  //      new_sort = parseFloat($(after).data("sort")) + 1;
  //    } else if(after === undefined) {
  //      new_sort = parseFloat($(before).data("sort")) - 1;
  //    } else {
  //      new_sort = (parseFloat($(before).data("sort")) + parseFloat($(after).data("sort")))/2;
  //    }

  //    $(ui.item).data("sort", new_sort);

  //    $.ajax({
  //      type: "POST",
  //      url: "/transactions/" + id,
  //      data: {
  //        transaction: {
  //          id: id,
  //          sort: new_sort
  //        },
  //        _method: 'put'
  //      },
  //      dataType: "json",
  //      success: function(xhr){
  //        //console.debug(xhr.responseText);
  //        //success = $.parseJSON(xhr.responseText);
  //        // TODO tie up with data refresh
  //      },
  //      error: function(xhr){
  //        //console.debug(xhr.responseText);
  //        //errors = $.parseJSON(xhr.responseText);
  //        // TODO do something with errors
  //      }
  //    });

  //    $(".transaction").slice(0, Math.max(prev_index, index) + 1).each(function(index, value){
  //      id = $(value).data("id");
  //      //console.debug(value);
  //      $.ajax({
  //        type: "GET",
  //        url: "/transactions/" + id,
  //        data: { },
  //        dataType: "json",
  //        success: function(data){
  //          balance_amount = Math.abs( parseFloat(data['balance']) ).toFixed(2);
  //          balance_sign = ( balance_amount != parseFloat(data['balance']) ) ? "-" : "";
  //          $("[data-id=" + data['id'] + "]").find('.balance_sign').html(balance_sign);
  //          $("[data-id=" + data['id'] + "] > .balance_amount").html(balance_amount);

  //          account_balance_amount = Math.abs( parseFloat(data['account_balance']) ).toFixed(2);
  //          account_balance_sign = ( account_balance_amount != parseFloat(data['account_balance']) ) ? "-" : "";
  //          $("[data-id=" + data['id'] + "]").find('.account_balance_sign').html(account_balance_sign);
  //          $("[data-id=" + data['id'] + "] > .account_balance_amount").html(account_balance_amount);
  //        },
  //        error: function(data){
  //          console.debug(xhr);
  //          //errors = $.parseJSON(xhr.responseText);
  //          // TODO do something with errors
  //        }
  //      });
  //    });
  //  },
  //  helper: function(e, tr){
  //    var $originals = tr.children();
  //    var $helper = tr.clone();
  //    $helper.children().each(function(index)
  //    {
  //      // Set helper cell sizes to match the original sizes
  //      $(this).width($originals.eq(index).width());
  //    });
  //    return $helper;
  //  }
  //});
});
