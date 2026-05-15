var KT = KT ? KT : {};
KT.hosts = {};

$(document).on('ContentLoad', function(){
    KT.hosts.onKatelloHostEditLoad();
    window.tfm.hosts.registerPluginAttributes("os",
         ['content_view_environment_id', 'content_source_id', 'architecture_id', 'parent_id']);

    KT.hosts.update_media_enablement();
    KT.hosts.set_media_selection_bindings();
});

KT.hosts.contentSourceChanged = function() {
  $("#hostgroup_content_view_environment_id").val("");
  $("#host_content_view_environment_id").val("");
  KT.hosts.refreshContentViewEnvironments();
};

KT.hosts.refreshContentViewEnvironments = function() {
  var select = $("#hostgroup_content_view_environment_id");
  if (select.length === 0) {
    select = $("#host_content_view_environment_id");
  }
  if (select.length === 0) return;

  var content_source_id = $('#content_source_id').val();
  var orgIdsElem = $("#hostgroup_organization_ids");
  var orgIds = orgIdsElem.val();

  if (orgIds === undefined || orgIds === null || orgIds.length === 0) {
    orgIds = orgIdsElem.data('useds');
  }
  if (orgIds === undefined || orgIds === null || orgIds.length === 0) {
    orgIds = [$("#host_organization_id").val()];
  }
  if (orgIds === undefined || orgIds === null || orgIds.length === 0) {
    return;
  }
  var orgId = Array.isArray(orgIds) ? orgIds[0] : orgIds;

  var inheritOption = select.find('option:first-child');
  var previousInheritText = inheritOption.text();
  var previousInheritDataId = inheritOption.attr('data-id');
  var previousValue = select.val();
  select.find('option').remove();

  var url = tfm.tools.foremanUrl('/katello/api/v2/content_view_environments');
  var params = { organization_id: orgId, full_result: true };

  if (content_source_id) {
    params.content_source_id = content_source_id;
  }

  $.get(url, params, function(data) {
    var foundPreviousValue = false;

    if (inheritOption.length && (inheritOption.val() === '' || previousInheritDataId)) {
      var inheritOpt = $("<option />").text(previousInheritText).val('');
      if (previousInheritDataId) inheritOpt.attr('data-id', previousInheritDataId);
      select.append(inheritOpt);
    }

    $.each(data.results, function(index, cvEnv) {
      var label = cvEnv.label;
      var option = $("<option />").val(cvEnv.id).text(label);
      if (cvEnv.id === parseInt(previousValue)) {
        option.prop('selected', true);
        foundPreviousValue = true;
      }
      select.append(option);
    });

    if (!foundPreviousValue) {
      select.val('');
    }

    select.trigger('change');
  });
};

KT.hosts.onKatelloHostEditLoad = function(){
    var prefixes = ['host', 'hostgroup'],
        attributes = ['content_view_environment_id', 'architecture_id'];

    $('body').off('.hostsContentSourceNS');

    $.each(prefixes, function(index, prefix) {
        $.each(attributes, function(attrIndex, attribute) {
            $('body').on('select2:select.hostsContentSourceNS select2:unselecting.hostsContentSourceNS', '#' + prefix + '_' + attribute, function () {
                KT.hosts.toggle_installation_medium();
            });
        });
    });

    $('body').on('select2:select.hostsContentSourceNS select2:unselecting.hostsContentSourceNS', '#content_source_id', function() {
        KT.hosts.contentSourceChanged();
        KT.hosts.toggle_installation_medium();
    });
};

KT.hosts.getSelectedContentViewEnvironment = function() {
    var cvEnvId = $("#hostgroup_content_view_environment_id").val();
    if (!cvEnvId) {
        cvEnvId = $("#host_content_view_environment_id").val();
    }
    if (!cvEnvId) {
        cvEnvId = $("#hostgroup_content_view_environment_id > option:selected").data("id");
    }
    if (!cvEnvId) {
        var hiddenInput = $("input[name='host[content_facet_attributes][content_view_environment_ids][]']").first();
        if (hiddenInput.length) {
            cvEnvId = hiddenInput.val();
        }
    }
    return cvEnvId;
};

KT.hosts.toggle_installation_medium = function() {
    var content_view_environment_id, content_source_id, architecture_id, operatingsystem_id;

    content_view_environment_id = KT.hosts.getSelectedContentViewEnvironment();
    content_source_id = $('#content_source_id').val();

    if ($('#hostgroup_operatingsystem_id').data('type') == 'hostgroup') {
      architecture_id = $('#hostgroup_architecture_id').val();
      operatingsystem_id = $('#hostgroup_operatingsystem_id').val();
    } else {
      architecture_id = $('#host_architecture_id').val();
      operatingsystem_id = $('#host_operatingsystem_id').val();
    }

    if (content_view_environment_id && content_source_id && architecture_id && operatingsystem_id) {
        os_selected(KT.hosts.get_os_element());
    }
};

KT.hosts.get_os_element = function () {
    var select = $("#host_operatingsystem_id").first();
    if(select.length === 0) {
        select = $("#hostgroup_operatingsystem_id").first();
    }
    return select;
};


KT.hosts.get_media_selection_div = function () {
    return $("#media_selection_section");
};

KT.hosts.get_install_media_div = function() {
    return KT.hosts.get_media_selection_div().next();
};

KT.hosts.get_synced_content_div = function() {
    return KT.hosts.get_media_selection_div().next().next();
};

KT.hosts.show_install_media = function(show) {
    if (show) {
        KT.hosts.get_install_media_div().show();
    } else {
        KT.hosts.get_install_media_div().hide();
    }
};

KT.hosts.show_synced_content = function(show) {
    if (show) {
        KT.hosts.get_synced_content_div().show();
    } else {
        KT.hosts.get_synced_content_div().hide();
    }
};

KT.hosts.update_media_type_selection = function (use_install_media) {
    var elements = KT.hosts.get_media_selector_elements();
    elements.filter('[value="install_media"]').prop('checked', use_install_media);
    elements.filter('[value="synced_content"]').prop('checked', !use_install_media);
    KT.hosts.update_media_enablement();
};

KT.hosts.media_selection_changed = function() {
    KT.hosts.show_install_media(this.value === "install_media");
    KT.hosts.show_synced_content(this.value !== "install_media");
};

KT.hosts.update_media_enablement = function () {
    var value = KT.hosts.is_install_media_selected();
    KT.hosts.show_install_media(value);
    KT.hosts.show_synced_content(!value);
};

KT.hosts.is_install_media_selected = function() {
    return KT.hosts.get_media_selector_elements().filter('[value="install_media"]').is(':checked');
};

KT.hosts.get_media_selector_elements = function() {
    return $('input:radio[data-media-selector]');
};

KT.hosts.get_synced_content_dropdown = function() {
    return $('select[data-kickstart-repository-id]');
};

KT.hosts.on_install_media_dropdown_change = function() {
    KT.hosts.get_synced_content_dropdown().val("");
    activate_select2("#media_select");
};

KT.hosts.on_synced_content_dropdown_change = function() {
    $("#host_medium_id").val("");
    $("#s2id_host_medium_id").val("");
    $("#hostgroup_medium_id").val("");
    $("#s2id_hostgroup_medium_id").val("");
    activate_select2("#media_select");
};

KT.hosts.set_install_media_bindings = function() {
    $("#host_medium_id").on("select2:select", KT.hosts.on_install_media_dropdown_change);
    $("#s2id_host_medium_id").on("select2:select", KT.hosts.on_install_media_dropdown_change);
    $("#hostgroup_medium_id").on("select2:select", KT.hosts.on_install_media_dropdown_change);
    $("#s2id_hostgroup_medium_id").on("select2:select", KT.hosts.on_install_media_dropdown_change);
};
KT.hosts.set_synced_content_bindings = function() {
    KT.hosts
      .get_synced_content_dropdown()
      .on('select2:select', KT.hosts.on_synced_content_dropdown_change);
};

KT.hosts.set_media_selection_bindings = function() {
  KT.hosts.set_install_media_bindings();
  KT.hosts.set_synced_content_bindings();
  KT.hosts.get_media_selector_elements().change(KT.hosts.media_selection_changed);
};
