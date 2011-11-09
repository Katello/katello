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


$(document).ready(function() {

    // Setup initial state
    var ids = [];
    $.each(KT.repo_status, function(repo_id, status){
      if (status.is_running) {
          ids.push(repo_id);
          KT.content.draw_syncing(repo_id, status.progress.progress);
      }
    });
    KT.content.reset_products(KT.repo_status);
    KT.content_actions.addSyncing(ids);


    KT.content.showAll();


    $('#select_all').click(KT.content.select_all);
    $('#select_none').click(KT.content.select_none);
    //$('#toggle_all').click(function(){$('tr').show(); });


    $("#products_table").delegate(".cancel_sync", "click", function(){
    var repo_id = $(this).parents("tr").attr("data-id");
    KT.actions.cancelSyncgetProductId(repo_id, $(this));
    });

    $('#sync_product_form').bind("ajax:success",
      function(evt, data, status, xhr){
       var syncs = $.parseJSON(data);
       var ids = [];
       $.each(syncs, function(index, item){
          ids.push(item.id);
          KT.content.draw_syncing(item.id, 0);
          KT.content.updateProduct(item.product_id, false, 0);
       });
       KT.content_actions.addSyncing(ids);

    });


    $("#sync_toggle").change(function(){
        var img = "<img  src='" + KT.common.spinner_path() + "'>";
        $("#list_actions").append(img);
        if ($(this).is(":checked")){
            KT.content.showOnlySyncing();
        }
        else {
            KT.content.showAll();
        }
        $("#list_actions").find("img").remove();
    });

  
});

KT.content_actions = (function(){
    var syncing = [],
    updater = undefined,
    addSyncing = function(repo_ids){
        if (repo_ids.length === 0){
            return;
        }
        //nothing in the list before adding and updater already exists
        var start = syncing.length === 0 && updater;
        $.each(repo_ids, function(index, id){
            syncing.push(id + "");
        });
        if (!updater){
            startUpdater();
        }
        else if (start){
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
               if (success == "notmodified") {
                 return;
               }
               $.each(data, function(index, repo){
                   // Only stop when we reach 100% and the finish_time is done sometimes they are not both complete
                   if (!repo.is_running) {
                        removeSyncing(repo.id);
                        KT.content.finishRepo(repo.id, repo.state, repo.duration);
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
               KT.content.reset_products(data);
            },
            function(){
                updater.stop();
            }
        );
            
    };

    return {
        cancelSync: cancelSync,
        addSyncing: addSyncing,
        startUpdater: startUpdater,
        getSyncing: function(){return syncing}
        
    };
})();


KT.content = (function(){

     var draw_syncing = function(repo_id, progress){

            var element = $("#repo-" + repo_id).find(".result"),
                cancelButton = $('<a/>').attr("class", "cancel_sync").text(i18n.cancel),
                progressBar = $('<div/>').attr('class', 'progress').text(" ");
            progress = progress ? progress : 0;
            progressBar.progressbar({
                value: progress
            });
            element.html("");
            element.append(progressBar).append(cancelButton);
        },
        updateRepo = function(repo_id, starttime, duration, progress, size, packages){
            var repo = $("#repo-" + repo_id);
            update_item(repo, starttime, duration, progress, size, packages );
        },
        finishRepo = function(repo_id, state, duration){
            var element = $("#repo-" + repo_id);
            element.find(".result").html(state);
            fadeUpdate(element.find(".duration"), duration);
        },
        cancelRepo = function(repo_id){
            //TODO handle product
            fadeUpdate($("#repo-" + repo_id).find(".result"), i18n.cancelled);
        },
        update_item = function(element, starttime, duration, progress, size, packages) {
            fadeUpdate(element.find(".start_time"), starttime);
            fadeUpdate(element.find(".duration"), duration);
            fadeUpdate(element.find(".size"), size + ' (' + packages + ')');
            var pg = element.find(".progress");
            if (progress === 100) { 
              pg.find(".ui-progressbar-value").animate({'width': 99 },{ queue:false,
                                               duration:"slow", easing:"easeInSine" });
            } 
            else {
              pg.progressbar({ value : progress});
            }
        },
        updateProduct = function (prod_id, done, percent) {
            var element = $("#product-" + prod_id).find(".result");
            var oldpg = element.find('.progress');
            if(done){
                element.html(i18n.complete);
            }
            else{
                var progressBar = $('<div/>').attr('class', 'progress').text(" ");
                element.html(progressBar);
                if(percent === 100) {
                  var past = oldpg ? oldpg.progressbar("option", "value") : 0;  
                  progressBar.progressbar({value: past});
                  progressBar.find(".ui-progressbar-value").animate({'width': 99 },{ queue:false,
                                               duration:"slow", easing:"easeInSine" });
                }
                else {
                  progressBar.progressbar({value: percent});
                }
            }
        },
        fadeUpdate = function(element, text) {
            element.fadeOut('fast').text(text);
            element.fadeIn('fast');
        },
        select_all = function(){
            $("#products_table").find("input[type=checkbox]").attr('checked',true);
        },
        select_none = function(){
            $("#products_table").find("input[type=checkbox]").removeAttr('checked');
        },
        reset_products = function(status_set){
            var products = {};
            $.each(status_set, function(index, item){
                var pid = item.product_id;
                if(products[pid] === undefined){
                    products[pid] = [];
                }
                if (item.is_running){
                    products[pid].push(item.progress.progress)
                }
            });
            $.each(products, function(prod_id, percentages){
                var total = 0;
                $.each(percentages, function(i, val){total += val;});
                updateProduct(prod_id, percentages.length === 0, total/percentages.length);

            });

        },
        showOnlySyncing = function(){
            $("#products_table").find("tbody").find("tr").hide();
            $.each(KT.content_actions.getSyncing(), function(index, repoid){
                var repo = $("#repo-" + repoid);
                showChain(repo);


            });
        },
        showChain = function(element){
            element.show().addClass("expanded").removeClass("collapsed");
            $.each(element.attr("class").split(" "), function(index, claz){
                if (claz.indexOf("child-of-") === 0){
                    var found = claz.split("child-of-")[1];
                    showChain($("#" + found));
                }
            });
        },
        showAll = function(){
            var rows = $("#products_table").find("tbody").find("tr").show().removeClass("expanded").addClass("collapsed");

            $("#products_table").treeTable({
                clickableNodeNames: true,
                indent: 15
            });
        };

    
    return {
        cancelRepo: cancelRepo,
        updateProduct: updateProduct,
        updateRepo: updateRepo,
        finishRepo: finishRepo,
        select_all : select_all,
        select_none: select_none,
        draw_syncing: draw_syncing,
        reset_products: reset_products,
        showOnlySyncing: showOnlySyncing,
        showAll: showAll
    }
})();
