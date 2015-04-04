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
  $('.datepicker').datepicker({
    dateFormat: "yy-mm-dd"
  });

  $("#transaction_filter_row").hide();
  $("#transaction_filter_row_toggle").click(function() {
    $("#transaction_filter_row").toggle();
  });

  $("#sortable").sortable({
    start: function(e, ui){
      $(this).data('previndex', ui.item.index());
    },
    update: function(e, ui){
      index = ui.item.index();
      prev_index = $(this).data('previndex');
      $(this).removeAttr('data-previndex');
      
      //console.debug(prev_index + " -> " + index)
      
      id = ui.item.data("id");
      
      before = $(this).children().get(index - 1);
      after = $(this).children().get(index + 1);

      if(index - 1 < 0) {
        new_sort = parseFloat($(after).data("sort")) + 1;
      } else if(after === undefined) {
        new_sort = parseFloat($(before).data("sort")) - 1;
      } else {
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

      $(".transaction").slice(0, Math.max(prev_index, index) + 1).each(function(index, value){
        id = $(value).data("id");
        //console.debug(value);
        $.ajax({
          type: "GET",
          url: "/transactions/" + id,
          data: { },
          dataType: "json",
          success: function(data){
            balance_amount = Math.abs( parseFloat(data['balance']) ).toFixed(2);
            balance_sign = ( balance_amount != parseFloat(data['balance']) ) ? "-" : "";
            $("[data-id=" + data['id'] + "]").find('.balance_sign').html(balance_sign);
            $("[data-id=" + data['id'] + "] > .balance_amount").html(balance_amount);

            account_balance_amount = Math.abs( parseFloat(data['account_balance']) ).toFixed(2);
            account_balance_sign = ( account_balance_amount != parseFloat(data['account_balance']) ) ? "-" : "";
            $("[data-id=" + data['id'] + "]").find('.account_balance_sign').html(account_balance_sign);
            $("[data-id=" + data['id'] + "] > .account_balance_amount").html(account_balance_amount);
          },
          error: function(data){
            console.debug(xhr);
            //errors = $.parseJSON(xhr.responseText);
            // TODO do something with errors
          }
        });
      });
    },
    helper: function(e, tr){
      var $originals = tr.children();
      var $helper = tr.clone();
      $helper.children().each(function(index)
      {
        // Set helper cell sizes to match the original sizes
        $(this).width($originals.eq(index).width());
      });
      return $helper;
    }
  });

  // $("tr.transaction:not(.editing)").click(function(){
  //   console.debug("Caught (.editing) click");
  //   $(this).addClass("editing");
  //   $(this).children("td.date").html('<input type="text" class="datepicker" value="' + $(this).children('td.date').html() + '">');
  // });

  // $(":not(.editing)").click(function(){
  //   console.debug("Caught :not(.editing) click");
  //   console.debug($("tr.editing"));
  //   $("tr.editing > td.date").html($("tr.editing > td.date > input").val());
  //   $('tr.editing').removeClass('editing');
  //   //post and revert
  // });

  $("a.edit").click(function(e){
    e.preventDefault();
    $(this).parents("tr").children("td.date").html('<input type="text" class="datepicker" value="' + $(this).parents("tr").children('td.date').html() + '">');
    $(this).parents("tr").children("td.budget_date").html('<input type="text" class="datepicker" value="' + $(this).parents("tr").children('td.budget_date').html() + '">');
    $(this).parents("tr").children("td.description").html('<input type="text" value="' + $(this).parents("tr").children('td.description').html() + '">');
    // Eurgh, td.amount doesn't exist, and you want to replace two cells with one otherwise it's gonna look shitty
    // see http://stackoverflow.com/questions/5264267/jquery-1-5-how-to-find-and-replace-2-cells-in-a-table-with-a-new-table-row-cell
    //$(this).parents("tr").children("td.amount").html('<input type="text" value="' + $(this).parents("tr").find('span.amount_sign').html() + $(this).parents("tr").children('td.amount_amount').html() + '">')
    $('.datepicker').datepicker({
      dateFormat: "yy-mm-dd"
    });
    $(this).parents("td").children("span").toggle();
  });

  $("a.save").click(function(e){
    e.preventDefault();
    // save
    // replace based on the data returned in ajax query
    //index = $(this).parents("tr").item.index();
    console.debug($(this).parents("tr")[0]);
    //console.debug(index);
   // $.ajax({
   //   type: "POST",
   //   url: "/transactions/" + id,
   //   data: {
   //     transaction: {
   //       id: id,
   //       date: date,
   //       bugdet_date: budget_date,

   //     },
   //     _method: 'put'
   //   },
   //   dataType: "json",
   //   success: function(xhr){
   //     //console.debug(xhr.responseText);
   //     //success = $.parseJSON(xhr.responseText);
   //     // TODO tie up with data refresh
   //   },
   //   error: function(xhr){
   //     //console.debug(xhr.responseText);
   //     //errors = $.parseJSON(xhr.responseText);
   //     // TODO do something with errors
   //   }
   // });
    
    // update those above
    $(this).parents("td").children("span").toggle();
  });

  $("a.cancel").click(function(e){
    e.preventDefault();
    // Fuck, you're an idiot. It's cancel. If you change the input values then they don't get reverted.
    $(this).parents("tr").children("td.date").html($(this).parents("tr").children('td.date').children('input').val());
    $(this).parents("tr").children("td.budget_date").html($(this).parents("tr").children('td.budget_date').children('input').val());
    $(this).parents("tr").children("td.description").html($(this).parents("tr").children('td.description').children('input').val());
    //amount = 
    //$(this).parents("tr").find("span.amount_sign").html($(this).parents("tr").children('td.description').children('input').val());
    //$(this).parents("tr").children("td.amount_amount").html($(this).parents("tr").children('td.description').children('input').val());
    $(this).parents("td").children("span").toggle();
  });
});
