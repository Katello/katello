/**
 Copyright 2011 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

function getProductId(field) {
    var prod_id = field.parent().attr('id').replace(/[^\d]+/,'');
    return prod_id;
}




$(document).ready(function() {

    // Setup initial state
    $.each(KT.repo_status, function(repo_id, rs){
      // If we have a sync_id for this repo, lets start the prog bar
      if (rs.sync_id) {
          KT.content_actions.addSyncing(repo_id);
          KT.content.draw_syncing(repo_id, rs.progress);
      }
    });

    KT.content_actions.startUpdater();

    $("#products_table").treeTable({
        clickableNodeNames: true,
        indent: 15
    });


    $('#select_all').click(KT.content.select_all);
    $('#select_none').click(KT.content.select_none);
    //$('#toggle_all').click(function(){$('tr').show(); });


    $("#products_table").delegate(".cancel_sync", "click", function(){
    var repo_id = $(this).parents("tr").attr("data-id");
    KT.actions.cancelSync(repo_id, $(this));
    });

    $('#sync_product_form').bind("ajax:success",
      function(evt, data, status, xhr){
       var syncs = $.parseJSON(data);
       $.each(syncs, function(index, item){
          KT.content_actions.addSyncing(item);
          KT.content.draw_syncing(item, 0);
       })

    });
  
  
  // if parent is checked then all children should be selected
//  $('.product input:checkbox').click(function() {
//    $(this).siblings().find('input:checkbox').attr('checked', this.checked);
//  });

  // if all children are checked, check the parent
  $('li.repo input:checkbox').click(function() {
    var td = $(this).parent().parent().parent();
    var parent_cbx = td.find('input:checkbox').first();
    var siblings = parent_cbx.siblings().find('input:checkbox');
    var total = siblings.length;
    var checked = 0;
    siblings.each( function() { if (this.checked == true) checked++; });
    if (total == checked) {
      parent_cbx.attr('checked', true);
    }
    else if (checked > 0) {
      parent_cbx.attr('checked', false);
    }
    else {
      parent_cbx.attr('checked', false);
    }

  });

});



KT.content_actions = (function(){
    var syncing = [],
    updater = undefined,
    addSyncing = function(repo_id){
        //nothing in the list before adding and updater already exists
        var start = syncing.length === 0 && updater;
        syncing.push(repo_id + "");
        if (!updater){
            startUpdater();
        }
        if (start){
            updater.restart();
        }
    },
    removeSyncing = function(repo_id){
      syncing.splice($.inArray(repo_id + "", syncing), 1);
      if (syncing.length === 0 && updater){
          updater.stop();
      }
    },
    getSyncing = function(){
        return syncing;
    },
    cancelSync = function(repo_id, btn){
        btn.addClass("disabled");
        
        $.ajax({
          type: 'DELETE',
          url: KT.routes.sync_management_path(repo_id),
          dataType: 'json',
          success: function(data) {
            KT.content.cancelRepo(repo_id);
          },
          error: function(data) {
            btn.removeClass("disabled");
          }
        });
    },
    startUpdater = function(){
        if (syncing.length ===0){
            return;
        }
        updater = $.PeriodicalUpdater(KT.routes.sync_management_sync_status_path(), {
              data: function(){return {repoids:getSyncing()}},
              method: 'get',
              type: 'json',
              global: false
            },
            function(data,success) {
               console.log(success);
               if (success == "notmodified") {
                 return;
               }
               $.each(data, function(index, repo){
                   // Only stop when we reach 100% and the finish_time is done sometimes they are not both complete
                   if (data.raw_state == 'canceled' || (data.progress.progress === 100 && data.finish_time)) {
                        removeSyncing(repo.id);
                   }
                   else {
                    KT.content.updateRepo(  repo.id,
                                            repo.start_time,
                                            repo.duration,
                                            repo.progress.progress,
                                            repo.size,
                                            repo.packages);
                   }
               });
            },
            function(){
                updater.stop();
            }
            );
            
    };

    return {
        cancelSync: cancelSync,
        addSyncing: addSyncing,
        startUpdater: startUpdater
        
    };
})();


KT.content = (function(){

     var draw_syncing = function(repo_id, progress){
            var element = $("#repo-" + repo_id).find(".result");
            var cancelButton = $('<a/>').attr("class", "cancel_sync").text(i18n.cancel);
            var progressBar = $('<div/>').attr('class', 'progress').text(" ");
            progress = progress ? progress : 0;
            progressBar.progressbar({
                value: progress
            });
            element.text("").append(progressBar).append(cancelButton);
        },
        updateRepo = function(repo_id, starttime, duration, progress, size, packages){
            var repo = $("#repo-" + repo_id);
            update_item(repo, starttime, duration, progress, size, packages );
        },
        cancelRepo = function(repo_id){
            //TODO handle product
            fadeUpdate($("#repo-" + repo_id).find(".result"), i18n.cancelled);
        },
        update_item = function(element, starttime, duration, progress, size, packages) {
            fadeUpdate(element.find(".start_time"), starttime);
            fadeUpdate(element.find(".duration"), duration);
            fadeUpdate(element.find(".size"), size + ' (' + packages + ')');
            element.find(".progress").progressbar({ value : progress});
            fadeUpdate(element.find(".result"), "");
        },
        updateProduct = function (prod_id, repo_id) {
//            var url = KT.routes.sync_management_product_status_path();
//            $.ajax({
//              type: 'GET',
//              url: url,
//              data: { product_id: prod_id, repo_id: repo_id},
//              dataType: 'json',
//              success: function(data) {
//                $('#table_' + prod_id).find('div.productstatus').html(data.state);
//                fadeUpdate("#prod_sync_finish_" + data.product_id, data.duration);
//                fadeUpdate("#prod_sync_start_" + data.product_id, data.start_time);
//                fadeUpdate("#prod_size_" + data.product_id, data.size);
//              },
//              error: function(data) {
//                fadeUpdate("#prod_sync_finish_" + data.product_id, data.duration);
//                fadeUpdate("#prod_sync_start_" + data.product_id, data.start_time);
//                fadeUpdate("#prod_size_" + data.product_id, data.size);
//              }
//            });
        },
        fadeUpdate = function(updateField, text) {
            updateField.fadeOut('fast').text(text).fadeIn('fast');
        },
        select_all = function(){
            $("#products_table").find("input[type=checkbox]").attr('checked',true);
        },
        select_none = function(){
            $("#products_table").find("input[type=checkbox]").removeAttr('checked');
        };
    
    return {
        cancelRepo: cancelRepo,
        updateProduct: updateProduct,
        updateRepo: updateRepo,
        select_all : select_all,
        select_none: select_none,
        draw_syncing: draw_syncing
    }
})();
