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
          KT.content.statusChecker(rs.id, rs.sync_id, rs.product_id);
      }
  });

    $("#products_table").treeTable({
        clickableNodeNames: true,
        indent: 15
    });

  


  $('#select_all').click(KT.content.select_all);
  $('#select_none').click(KT.content.select_none);
  //$('#toggle_all').click(function(){$('tr').show(); });

  // start polling sync status after succesfully sync call
  $('#sync_product_form').bind("ajax:success",
      function(evt, data, status, xhr){
       var syncs = $.parseJSON(data);
       $.each(syncs, function(){
           KT.content.statusChecker(this.repo_id, this.sync_id, this.product_id);
       })
   }).bind("ajax:error", function(evt, xhr, status, error){});
  
  

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


  //end doc ready
});



KT.content_actions = (function(){


    return {


    };
});





KT.content = (function(){

     var   statusChecker = function(repo, sync, product_id){
            fadeUpdate("#prod_sync_start_" + product_id, ' ');
            var updateField = $('#' + KT.common.escapeId("repo_bar_" + repo));
            updateField.fadeOut('fast');
            updateField.html('');
            cancelButton = $('<a/>')
                .attr("id", "cancel_"+repo)
                .attr("class", "cancel")
                .attr("href", "#")
                .text(i18n.cancel);
            progressBar = $('<div/>')
                .attr('class', 'progress')
                .attr('id', "progress_" + repo)
                .text(" ");
            progressBar.progressbar({
                value: 0
            });
            progressBar.appendTo(updateField);
            cancelButton.appendTo(updateField);
            updateField.fadeIn('fast');
            var url = $('#sync_status_url').attr('data-url');
            var pu = $.PeriodicalUpdater(url, {
              data: {repo_id:repo, sync_id:sync},
              method: 'get',
              type: 'json',
              global: false
            }, function(data,success) {
               if (success == "notmodified") {
                 return;
               }
               var pb = $('#progress_' + data.repo_id);
               var prod_id = getProductId(updateField);
               $("#repo_sync_start_" + data.repo_id).text(data.start_time);
               // Only stop when we reach 100% and the finish_time is done
               // sometimes they arent both complete
               if (data.raw_state == 'canceled' || (data.progress.progress == 100 && data.finish_time != null)) {
                 pu.stop();
                 updateField.html(data.state);
                 fadeUpdate("#repo_sync_finish_" + data.repo_id, data.duration);
                 fadeUpdate("#repo_sync_size_" + data.repo_id,
                             data.size + ' (' + data.packages + ')');
                 updateProduct(prod_id, data.repo_id);
               } else if (data.progress.progress < 0) {
                 pu.stop();
                 updateField.html(i18n.error);
                 updateProduct(prod_id, data.repo_id);
               } else {
                 pb.progressbar({ value : data.progress.progress});
                 fadeUpdate("#repo_sync_size_" + data.repo_id, data.size + ' (' + data.packages + ')');
               }
            });
            cancelButton.click(function(){
                cancelSync(repo, sync, updateField, pu);
            });
            return false;
        },
        updateRepo = function(repo_id, starttime, duration, progress, size, packages){
            var repo = $("#repo-" + repo_id);
            fadeUpdate(repo.find(".start_time"), starttime);
            fadeUpdate(repo.find(".duration"), duration);
            fadeUpdate(repo.find(".size"), size + ' (' + packages + ')');
            fadeUpdate(repo.find(".result"), "");
        },
        updateProduct = function (prod_id, repo_id) {
            var url = KT.routes.sync_management_product_status_path();
            $.ajax({
              type: 'GET',
              url: url,
              data: { product_id: prod_id, repo_id: repo_id},
              dataType: 'json',
              success: function(data) {
                $('#table_' + prod_id).find('div.productstatus').html(data.state);
                fadeUpdate("#prod_sync_finish_" + data.product_id, data.duration);
                fadeUpdate("#prod_sync_start_" + data.product_id, data.start_time);
                fadeUpdate("#prod_size_" + data.product_id, data.size);
              },
              error: function(data) {
                fadeUpdate("#prod_sync_finish_" + data.product_id, data.duration);
                fadeUpdate("#prod_sync_start_" + data.product_id, data.start_time);
                fadeUpdate("#prod_size_" + data.product_id, data.size);
              }
            });
        },
        cancelSync = function(repoid, syncid, updateField, pu){
            var btn = $('#' + KT.common.escapeId("cancel_" + repoid)),
                prod_id = getProductId(updateField);
            btn.addClass("disabled");
            pu.stop();
            $.ajax({
              type: 'DELETE',
              url: KT.common.rootURL() + 'sync_management/' + syncid,
              data: { repo_id: repoid, product_id: prod_id },
              dataType: 'json',
              success: function(data) {
                updateProduct(prod_id, repoid);
                updateField.html('Sync Canceled.');
              },
              error: function(data) {
                btn.removeClass("disabled");
              }
            });
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
        cancelSync: cancelSync,
        updateProduct: updateProduct,
        statusChecker: statusChecker,
        select_all : select_all,
        select_none: select_none
    }
})();
