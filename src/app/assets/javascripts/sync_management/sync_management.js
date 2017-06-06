/**
 Copyright 2013 Red Hat, Inc.

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




    $('#select_all').click(KT.content.select_all);
    $('#select_none').click(KT.content.select_none);
    $('#collapse_all').click(KT.content.collapse_all);
    $('#expand_all').click(KT.content.expand_all);

    KT.content.showAll();

    $("#products_table").delegate(".cancel_sync", "click", function(){
        var repo_id = $(this).parents("tr").attr("data-id");
        KT.content_actions.cancelSync(repo_id, $(this));
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

    })
    .bind("ajax:beforeSend",
      function(evt, data, status, xhr) {
        if ($("input[name='repoids[]']:checked").length === 0) {
          return false;
        }
    });


    $("#sync_toggle").change(function(){
        var img = "<img  src='" + KT.common.spinner_path() + "'>";
        $("#sync_toggle_cont").append(img);
        if ($(this).is(":checked")){
            KT.content.showOnlySyncing();
        }
        else {
            KT.content.showAll();
        }
        $("#sync_toggle_cont").find("img").remove();
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
    cancelSync = function(repo_id){
        var button = $("#repo-" + repo_id).find(".result .cancel_sync");

        if( !$(button).hasClass('disabled') ){
            button.addClass('disabled');

            $.ajax({
              type: 'DELETE',
              url: KT.routes.sync_management_path(repo_id),
              dataType: 'json',
              success: function(data) {
              },
              error: function(data) {
                    button.removeClass('disabled');
              }
            });
        }
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
                   if (!repo.is_running && (repo.raw_state !== 'waiting')) {
                        removeSyncing(repo.id);
                        KT.content.finishRepo(repo.id, repo.state, repo.duration);
                        KT.content.updateRepo(repo.id, repo.start_time, repo.duration, repo.progress.progress, repo.display_size, repo.packages, repo.size);
                        KT.content.updateProduct(repo.product_id, false, false, true);
                        notices.checkNotices();
                   }
                   else {
                    KT.content.updateRepo(  repo.id,
                                            repo.start_time,
                                            repo.duration,
                                            repo.progress.progress,
                                            repo.display_size,
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
            element.append(progressBar);
            if( KT.permissions.syncable ){
                element.append(cancelButton);
            }
        },
        updateRepo = function(repo_id, starttime, duration, progress, display_size, packages, size){
            var repo = $("#repo-" + repo_id);
            update_item(repo, starttime, duration, progress, display_size, packages, size );
        },
        finishRepo = function(repo_id, state, duration){
            var element = $("#repo-" + repo_id);
            element.find(".result").html(state);
            fadeUpdate(element.find(".duration"), duration);
        },
        update_item = function(element, starttime, duration, progress, display_size, packages, size) {
            var pg = element.find(".progress"),
                value = pg.find(".ui-progressbar-value");

            fadeUpdate(element.find(".start_time"), starttime);
            // clear duration during active sync
            fadeUpdate(element.find(".duration"), '');
            fadeUpdate(element.find(".size"), display_size + ' (' + packages + ')');
            element.find('.size').data('size', size);
            progress = progress == 100 ? 99 : progress;
            value.animate({'width': progress },{ queue:false,
                                           duration:"slow", easing:"easeInSine" });
        },
        updateProduct = function (prod_id, done, percent, size) {
            var product_element = $("#product-" + prod_id),
                element = product_element.find(".result"),
                oldpg = element.find('.progress');

            if( size ){
                size = KT.utils.reduce($('table').find("[data-product_id=" + prod_id + "]").find('.size'), function(memo, num){ return $(num).data('size') + memo;}, 0);
                fadeUpdate(product_element.find('.size'), KT.common.to_human_readable_bytes(size));
            } else if(done){
                element.html("");
            }
            else{
                if (oldpg.length == 0){
                    element.html($('<div/>').attr('class', 'progress').text(" "));
                    element.find(".progress").progressbar({value: 0});
                }
                else {
                    var value = oldpg.find(".ui-progressbar-value");
                    percent = percent == 100 ? 99 : percent;
                    value.animate({'width': percent },{ queue:false,
                          duration:"slow", easing:"easeInSine" });
                }
            }
        },
        fadeUpdate = function(element, text) {
            //element.fadeOut('fast').text(text);
            //element.fadeIn('fast');
            element.text(text);
        },
        select_all = function(){
            $("#products_table").find("input[type=checkbox]").attr('checked',true);
        },
        select_none = function(){
            $("#products_table").find("input[type=checkbox]").removeAttr('checked');
        },
        select_repo = function(){
            $("input[name='repoids[]']:checked").length > 0 ?
                $("#sync_button").removeClass("disabled") :
                $("#sync_button").addClass("disabled");
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
        },
        expand_all = function() {
          $("#products_table").find("tr").removeClass("collapsed").addClass("expanded").each(function(){
            $(this).expand();
          });
        },
        collapse_all = function() {
          $("#products_table").find("tr").removeClass("expanded").addClass("collapsed").each(function(){
            $(this).collapse();
          });
        };

    return {
        updateProduct: updateProduct,
        updateRepo: updateRepo,
        finishRepo: finishRepo,
        select_all : select_all,
        select_none: select_none,
        select_repo: select_repo,
        draw_syncing: draw_syncing,
        reset_products: reset_products,
        showOnlySyncing: showOnlySyncing,
        showAll: showAll,
        expand_all: expand_all,
        collapse_all: collapse_all
    }
})();
