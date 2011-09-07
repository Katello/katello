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

function getProductIdFromRepo(repo_id) {
    return $('#' + "repo_"  +repo_id).parents('.product').attr('data-id')
}

function fadeUpdate(fieldName, text) {
  var updateField = $(fieldName);
  updateField.fadeOut('fast');
  updateField.text(text);
  updateField.fadeIn('fast');
}

$(document).ready(function() {

  // Setup initial state
  for (var i = 0; i < repo_status.length; i++) {
      var rs = repo_status[i];
      // If we have a sync_id for this repo, lets start the prog bar
      if (rs[1] !== "") {
          content.statusChecker(rs[0], rs[1], rs[2]);
      }
  }

  // check box collections
  $('#select_all').click(function(){$('.products input:checkbox').attr('checked',true); return false;});
  $('#select_none').click(function(){$('.products input:checkbox').attr('checked',false); return false;});
  $('#toggle_all').click(function(){$('.clickable').click(); return false;});

  // start polling sync status after succesfully sync call
  $('#sync_product_form')
   .bind("ajax:success", function(evt, data, status, xhr){
       var syncs = $.parseJSON(data);
       $.each(syncs, function(){
           content.statusChecker(this.repo_id, this.sync_id, this.product_id);
       })
   })
   .bind("ajax:error", function(evt, xhr, status, error){
   });
  
  // drop down arrows for parent product and child repos
  $('.products').find('ul').slideToggle();
  $('.clickable').live('click', function(){

      // Hide the start/stop times
      var prod_id = $(this).parent().find('input').attr('id').replace(/[^\d]+/,'');

      $(this).parent().parent().find('ul').slideToggle();
      var arrow = $(this).parent().find('a').find('img');
      if(arrow.attr("src").indexOf("collapsed") === -1){
          arrow.attr("src", "/images/icons/expander-collapsed.png");
      } else {
          arrow.attr("src", "/images/icons/expander-expanded.png");
      }
      return false;
  });

  // if parent is checked then all children should be selected
  $('.product input:checkbox').click(function() {
    $(this).siblings().find('input:checkbox').attr('checked', this.checked);
  });

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


var content = (function(){
    return {
        statusChecker : function(repo, sync, product_id){
            fadeUpdate("#prod_sync_start_" + product_id, ' ');
            var updateField = $('#' + KT.common.escapeId("repo_bar_" + repo));
            updateField.fadeOut('fast');
            updateField.html('');
            cancelButton = $('<a/>')
                .attr("id", "cancel_"+repo)
                .attr("class", "fr")
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
            var pu = $.PeriodicalUpdater('/sync_management/sync_status/', {
              data: {repo_id:repo, sync_id:sync, product_id: getProductIdFromRepo(repo)},
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
               if (data.progress.progress == 100 && data.finish_time != null) {
                 pu.stop();
                 updateField.html(data.state);
                 fadeUpdate("#repo_sync_finish_" + data.repo_id, data.finish_time);
                 fadeUpdate("#repo_sync_size_" + data.repo_id,
                             data.size + ' (' + data.packages + ')');
                 content.updateProduct(prod_id, data.repo_id);
               } else if (data.progress.progress < 0) {
                 pu.stop();
                 updateField.html(i18n.error);
                 content.updateProduct(prod_id, data.repo_id);
               } else {
                 pb.progressbar({ value : data.progress.progress});
                 fadeUpdate("#repo_sync_size_" + data.repo_id, data.size + ' (' + data.packages + ')');
               }
            });
            cancelButton.click(function(){
                content.cancelSync(repo, sync, updateField, pu);
            })
            return false;
        },
        updateProduct : function (prod_id, repo_id) {
            $.ajax({
              type: 'GET',
              url: '/sync_management/product_status/',
              data: { product_id: prod_id, repo_id: repo_id},
              dataType: 'json',
              success: function(data) {
                $('#table_' + prod_id).find('div.productstatus').html(data.state);
                fadeUpdate("#prod_sync_finish_" + data.product_id, data.finish_time);
                fadeUpdate("#prod_sync_start_" + data.product_id, data.start_time);
                fadeUpdate("#prod_size_" + data.product_id, data.size);
              },
              error: function(data) {
                fadeUpdate("#prod_sync_finish_" + data.product_id, data.finish_time);
                fadeUpdate("#prod_sync_start_" + data.product_id, data.start_time);
                fadeUpdate("#prod_size_" + data.product_id, data.size);
              }
            });
        },
        cancelSync : function(repoid, syncid, updateField, pu){
            var btn = $('#' + KT.common.escapeId("cancel_" + repoid));
            var prod_id = getProductId(updateField);
            btn.addClass("disabled");
            pu.stop();
            $.ajax({
              type: 'DELETE',
              url: '/sync_management/' + syncid,
              data: { repo_id: repoid, product_id: prod_id },
              dataType: 'json',
              success: function(data) {
                content.updateProduct(prod_id, repoid);
                updateField.html('Sync Cancelled.');
              },
              error: function(data) {
                btn.removeClass("disabled");
              }
            });
        }
    }
})();
