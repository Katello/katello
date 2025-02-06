KT.content = (function () {
  var draw_syncing = function (repo_id, progress, task_id) {
      var element = $("#repo-" + repo_id).find(".result"),
        cancelButton = $("<a/>").attr("class", "cancel_sync").text(katelloI18n.cancel),
        progressBar = $("<a/>").attr("class", "progress").text(" ");

      if (task_id !== undefined) {
        progressBar.attr("href", tfm.tools.foremanUrl("/foreman_tasks/tasks/" + task_id));
      }

      progress = progress ? progress : 0;
      progressBar.progressbar({
        value: progress,
      });
      element.find(".result-info").html("");
      element.find(".result-info").append(progressBar);
      element.find(".info-tipsy").addClass("hidden");

      if (KT.permissions.syncable) {
        element.find(".result-info").append(cancelButton);
      }
    },
    updateRepo = function (
      repo_id,
      starttime,
      duration,
      progress,
      display_size,
      packages,
      size,
      task_id
    ) {
      var repo = $("#repo-" + repo_id);
      update_item(repo, starttime, duration, progress, display_size, packages, size, task_id);
    },
    finishRepo = function (repo_id, state, duration, raw_state, error_details, task_id) {
      var element = $("#repo-" + repo_id);
      var messages = [];
      var url = tfm.tools.foremanUrl("/foreman_tasks/tasks/" + task_id);
      state = '<a href="' + url + '">' + state + "</a>";
      element.find(".result .result-info").html(state);
      fadeUpdate(element.find(".duration"), duration);

      if (raw_state === "error") {
        element.find(".result .info-tipsy").removeClass("hidden");

        KT.utils.forEach(error_details["messages"], function (message) {
          messages.push("<li>" + message + "</li>");
        });

        element.find(".result .info-tipsy ul").html(messages.join(""));
      }
    },
    update_item = function (
      element,
      starttime,
      duration,
      progress,
      display_size,
      packages,
      size,
      task_id
    ) {
      var pg = element.find(".progress"),
        value = pg.find(".ui-progressbar-value");

      starttime = starttime === null ? katelloI18n.no_start_time : starttime;

      if (task_id !== undefined) {
        pg.attr("href", tfm.tools.foremanUrl("/foreman_tasks/tasks/" + task_id));
      }

      fadeUpdate(element.find(".start_time"), starttime);
      // clear duration during active sync
      fadeUpdate(element.find(".duration"), "");
      fadeUpdate(element.find(".size"), display_size);
      element.find(".size").data("size", size);
      element
        .find(".info-tipsy")
        .attr("href", tfm.tools.foremanUrl("/foreman_tasks/tasks/" + task_id));
      progress = progress === 100 ? 99 : progress;
      value.show();
      value.animate({ width: progress }, { queue: false, duration: "slow", easing: "easeInSine" });
    },
    updateProduct = function (prod_id, done, percent, size) {
      var product_element = $("#product-" + prod_id),
        element = product_element.find(".result"),
        oldpg = element.find(".progress");

      if (size) {
        size = KT.utils.reduce(
          $("table")
            .find("[data-product_id=" + prod_id + "]")
            .find(".size"),
          function (memo, num) {
            return $(num).data("size") + memo;
          },
          0
        );
        fadeUpdate(product_element.find(".size"), KT.common.to_human_readable_bytes(size));
      } else if (done) {
        element.html("");
      } else {
        if (oldpg.length === 0) {
          element.html($("<div/>").attr("class", "progress").text(" "));
          element.find(".progress").progressbar({ value: 0 });
        } else {
          var value = oldpg.find(".ui-progressbar-value");
          percent = percent === 100 ? 99 : percent;
          value.animate(
            { width: percent },
            { queue: false, duration: "slow", easing: "easeInSine" }
          );
        }
      }
    },
    fadeUpdate = function (element, text) {
      //element.fadeOut('fast').text(text);
      //element.fadeIn('fast');
      element.text(text);
    },
    select_all = function () {
      $("#products_table").find("input[type=checkbox]").prop("checked", true);
      KT.content.select_repo();
    },
    select_none = function () {
      $("#products_table").find("input[type=checkbox]").prop("checked", false);
      KT.content.select_repo();
    },
    select_repo = function () {
      if ($("input[name='repoids[]']:checked").length > 0) {
        $("#sync_button").removeClass("disabled");
      } else {
        $("#sync_button").addClass("disabled");
      }
    },
    reset_products = function (status_set) {
      var products = {};
      $.each(status_set, function (index, item) {
        var pid = item.product_id;
        if (products[pid] === undefined) {
          products[pid] = [];
        }
        if (item.is_running) {
          products[pid].push(item.progress.progress);
        }
      });
      $.each(products, function (prod_id, percentages) {
        var total = 0;
        $.each(percentages, function (i, val) {
          total += val;
        });
        updateProduct(prod_id, percentages.length === 0, total / percentages.length);
      });
    },
    showOnlySyncing = function () {
      $("#products_table").find("tbody").find("tr").hide();
      $.each(KT.content_actions.getSyncing(), function (index, repoid) {
        var repo = $("#repo-" + repoid);
        showChain(repo);
      });
    },
    showChain = function (element) {
      element.show().addClass("expanded").removeClass("collapsed");
      $.each(element.attr("class").split(" "), function (index, claz) {
        if (claz.indexOf("child-of-") === 0) {
          var found = claz.split("child-of-")[1];
          showChain($("#" + found));
        }
      });
    },
    showAll = function () {
      var rows = $("#products_table")
        .find("tbody")
        .find("tr")
        .show()
        .removeClass("expanded")
        .addClass("collapsed");

      $("#products_table").treeTable({
        clickableNodeNames: true,
        indent: 15,
      });
    },
    expand_all = function () {
      var sync_toggle = $("#sync_toggle");
      if ($(sync_toggle).is(":checked")) {
        $(sync_toggle).prop("checked", false);
        KT.content.showAll();
      }
      $("#products_table")
        .find("tr")
        .removeClass("collapsed")
        .addClass("expanded")
        .each(function () {
          $(this).expand();
        });
    },
    collapse_all = function () {
      $("#products_table")
        .find("tr")
        .removeClass("expanded")
        .addClass("collapsed")
        .each(function () {
          $(this).collapse();
        });
    };
    populate_repo_status = function () {
      var ids = [];
      $.each(KT.repo_status, function (repo_id, status) {
        if (status.is_running) {
          ids.push(repo_id);
          KT.content.draw_syncing(repo_id, status.progress.progress, status.sync_id);
        }
      });
      KT.content.reset_products(KT.repo_status);
      KT.content_actions.addSyncing(ids);
    }

  return {
    updateProduct: updateProduct,
    updateRepo: updateRepo,
    populateRepoStatus: populate_repo_status,
    finishRepo: finishRepo,
    select_all: select_all,
    select_none: select_none,
    select_repo: select_repo,
    draw_syncing: draw_syncing,
    reset_products: reset_products,
    showOnlySyncing: showOnlySyncing,
    showAll: showAll,
    expand_all: expand_all,
    collapse_all: collapse_all,
  };
})();
// Setup initial state

KT.content_actions = (function () {
  var syncing = [],
    updater,
    getOrg = function () {
      return $("#organization_id").val();
    },
    addSyncing = function (repo_ids) {
      if (repo_ids.length === 0) {
        return;
      }
      //nothing in the list before adding and updater already exists
      var start = syncing.length === 0 && updater;
      $.each(repo_ids, function (index, id) {
        syncing.push(id + "");
      });
      if (!updater) {
        startUpdater();
      } else if (start) {
        updater.restart();
      }
    },
    removeSyncing = function (repo_id) {
      syncing.splice($.inArray(repo_id + "", syncing), 1);
      if (syncing.length === 0 && updater) {
        updater.stop();
      }
    },
    getSyncing = function () {
      return syncing;
    },
    cancelSync = function (repo_id) {
      var button = $("#repo-" + repo_id).find(".result .cancel_sync");

      if (!$(button).hasClass("disabled")) {
        button.addClass("disabled");

        $.ajax({
          type: "DELETE",
          url: tfm.tools.foremanUrl(
            "/katello/sync_management/" + repo_id + "?organization_id=" + getOrg()
          ),
          dataType: "json",
          success: function (data) {},
          error: function (data) {
            button.removeClass("disabled");
          },
        });
      }
    },
    startUpdater = function () {
      if (syncing.length === 0) {
        return;
      }
      var url = tfm.tools.foremanUrl("/katello/sync_management/sync_status");
      updater = $.PeriodicalUpdater(
        url,
        {
          data: function () {
            return { repoids: getSyncing(), organization_id: getOrg() };
          },
          method: "get",
          type: "json",
          global: false,
        },
        function (data, success) {
          if (success === "notmodified") {
            return;
          }
          $.each(data, function (index, repo) {
            // Only stop when we reach 100% and the finish_time is done sometimes they are not both complete
            if (!repo.is_running && repo.raw_state !== "waiting") {
              removeSyncing(repo.id);
              KT.content.updateRepo(
                repo.id,
                repo.start_time,
                repo.duration,
                repo.progress.progress,
                repo.display_size,
                repo.packages,
                repo.size,
                repo.sync_id
              );
              KT.content.finishRepo(
                repo.id,
                repo.state,
                repo.duration,
                repo.raw_state,
                repo.error_details,
                repo.sync_id
              );
              KT.content.updateProduct(repo.product_id, false, false, true);
            } else {
              KT.content.updateRepo(
                repo.id,
                repo.start_time,
                repo.duration,
                repo.progress.progress,
                repo.display_size,
                repo.packages,
                repo.size,
                repo.sync_id
              );
            }
          });
          KT.content.reset_products(data);
        },
        function () {
          updater.stop();
        }
      );
      updater.restart();
    };

  return {
    cancelSync: cancelSync,
    addSyncing: addSyncing,
    startUpdater: startUpdater,
    getSyncing: function () {
      return syncing;
    },
  };
})();

KT.content.populateRepoStatus();

$("#select_all").on("click", KT.content.select_all);
$("#select_none").on("click", KT.content.select_none);
$("#collapse_all").on("click", KT.content.collapse_all);
$("#expand_all").on("click", KT.content.expand_all);

KT.content.showAll();
KT.content.select_repo();

$("#products_table").on("click", ".cancel_sync", function () {
  var repo_id = $(this).parents("tr").attr("data-id");
  KT.content_actions.cancelSync(repo_id, $(this));
});

$("#sync_product_form")
  .on("ajax:success", function (evt, data, status, xhr) {
    var ids = [];
    $.each(data, function (index, item) {
      ids.push(item.id);
      KT.content.draw_syncing(item.id, 0, undefined);
      KT.content.updateProduct(item.product_id, false, 0);
    });
    KT.content_actions.addSyncing(ids);
  })
  .on("ajax:beforeSend", function (evt, data, status, xhr) {
    if ($("input[name='repoids[]']:checked").length === 0) {
      return false;
    }
  });

$("#sync_toggle").on("change", function () {
  var img = "<img src='" + KT.common.spinner_path() + "'>";
  $("#sync_toggle_cont").append(img);
  if ($(this).is(":checked")) {
    KT.content.showOnlySyncing();
  } else {
    KT.content.showAll();
  }
  $("#sync_toggle_cont").find("img").remove();
});

$.each($("input[name='repoids[]']"), function (index, checkbox) {
  $(checkbox).on("click", KT.content.select_repo);
});
