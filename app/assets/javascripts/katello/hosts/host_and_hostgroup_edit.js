var KT = KT ? KT : {};
KT.hosts = {};

$(document).on('ContentLoad', function(){
    KT.hosts.onKatelloHostEditLoad();
    window.tfm.hosts.registerPluginAttributes("os",
         ['lifecycle_environment_id', 'content_view_id', 'environment_id', 'content_source_id', 'architecture_id']);

    $("#hostgroup_lifecycle_environment_id").change(KT.hosts.environmentChanged);
    $("#host_lifecycle_environment_id").change(KT.hosts.environmentChanged);

    $("#hostgroup_content_view_id").change(KT.hosts.contentViewSelected);
    $("#host_content_view_id").change(KT.hosts.contentViewSelected);
    $("#reset_puppet_environment").click(function() {
        KT.hosts.getPuppetEnvironmentSelect().data('content_puppet_match', 'true');
        KT.hosts.setDefaultPuppetEnvironment(KT.hosts.getSelectedContentView(), KT.hosts.getSelectedEnvironment());
    });
    KT.hosts.update_media_enablement();
    KT.hosts.set_media_selection_bindings();
});

KT.hosts.environmentChanged = function() {
  // if we don't save the currently selected view it's likely
  // it will be undefined in toggle_installation_medium due to the CV dropdown reload
  var previous_content_view = KT.hosts.getSelectedContentView();

  KT.hosts.fetchContentViews();
  KT.hosts.toggle_installation_medium(previous_content_view);
};

KT.hosts.fetchContentViews = function () {
    var select = KT.hosts.getContentViewSelect();
    var envId = KT.hosts.getSelectedEnvironment();
    var option;
    var previous_view = KT.hosts.getSelectedContentView();

    select.find('option').remove();
    if (envId) {
        KT.hosts.signalContentViewFetch(true);
        var url = tfm.tools.foremanUrl('/katello/api/v2/content_views/');
        $.get(url, {environment_id: envId, full_result: true}, function (data) {
            select.append($("<option />"));
            $.each(data.results, function(index, view) {
                option = $("<option />").val(view.id).text(view.name);
                if (view.id === parseInt(previous_view)) {
                  option.prop('selected', true);
                }
                select.append(option);
            });
            KT.hosts.signalContentViewFetch(false);
        });
    }
};

KT.hosts.signalContentViewFetch = function(fetching) {
    var select = KT.hosts.getContentViewSelect();
    var select2 = KT.hosts.getContentViewSelect2();
        spinner = $('<img>').attr('src', select.data("spinner-path")),
        spinner_id = "content_view_spinner";

    if(fetching) {
        select.hide();
        select2.hide();
        $(spinner).attr('id', spinner_id).insertAfter(select);
    } else {
        select2.show();
        $('#' + spinner_id).remove();
    }
};


KT.hosts.contentViewSelected = function() {
    if (KT.hosts.getPuppetEnvironmentSelect().data('content_puppet_match')) {
        KT.hosts.setDefaultPuppetEnvironment(KT.hosts.getSelectedContentView(), KT.hosts.getSelectedEnvironment());
    }
};

KT.hosts.setDefaultPuppetEnvironment = function(view_id, env_id) {
    if (view_id && env_id) {
        $.get('/hosts/puppet_environment_for_content_view', {content_view_id: view_id, lifecycle_environment_id: env_id}, function (data) {
            var select = KT.hosts.getPuppetEnvironmentSelect();
            if (data !== null) {
                select.val(data.id);
                select.trigger('change');
            }
        })
    }
};

KT.hosts.getPuppetEnvironmentSelect = function() {
    var select = $("#host_environment_id").first();
    if(select.length === 0) {
        select = $("#hostgroup_environment_id").first();
    }
    return select;
};

KT.hosts.getContentViewSelect2 = function() {
    var select = $("#s2id_host_content_view_id").first();
    if(select.length === 0) {
        select = $("#s2id_hostgroup_content_view_id").first();
    }
    return select;
};

KT.hosts.getContentViewSelect = function() {
    var select = $("#host_content_view_id").first();
    if(select.length === 0) {
        select = $("#hostgroup_content_view_id").first();
    }
    return select;
};

KT.hosts.getSelectedContentView = function() {
    var select = KT.hosts.getContentViewSelect();
    return select.val() || select.find("option:selected").data("id");
};

KT.hosts.getSelectedEnvironment = function () {
    var envId = $("#hostgroup_lifecycle_environment_id").val();
    if(envId === undefined || envId.length === 0) {
        envId = $("#host_lifecycle_environment_id").val()
    }
    if(envId === undefined || envId.length === 0) {
        envId = $("#hostgroup_lifecycle_environment_id > option:selected").data("id");
    }

    if(envId && envId.length === 0) {
        envId = undefined;
    }
    return envId;
};

KT.hosts.onKatelloHostEditLoad = function(){
    var prefixes = ['host', 'hostgroup'],
        attributes = ['content_view_id', 'environment_id', 'architecture_id'];

    $.each(prefixes, function(index, prefix) {
        $.each(attributes, function(attrIndex, attribute) {
            $('body').on('change', '#' + prefix + '_' + attribute, function () {
                KT.hosts.toggle_installation_medium();
            });
        });
    });

    $('body').on('change', '#content_source_id', function () {
        KT.hosts.toggle_installation_medium();
    });
};

KT.hosts.toggle_installation_medium = function(content_view_id) {
    var lifecycle_environment_id, content_source_id, architecture_id, operatingsystem_id;

    if (content_view_id === undefined) {
      content_view_id = KT.hosts.getSelectedContentView();
    }

    if ($('#hostgroup_parent_id').length > 0) {
      lifecycle_environment_id = KT.hosts.getSelectedEnvironment();
      content_source_id = $('#content_source_id').val();
      architecture_id = $('#hostgroup_architecture_id').val();
      operatingsystem_id = $('#hostgroup_operatingsystem_id').val();
    } else {
      lifecycle_environment_id = KT.hosts.getSelectedEnvironment();
      content_source_id = $('#content_source_id').val();
      architecture_id = $('#host_architecture_id').val();
      operatingsystem_id = $('#host_operatingsystem_id').val();
    }

    if (content_view_id && lifecycle_environment_id && content_source_id && architecture_id && operatingsystem_id) {
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
    // reset the kickstart-repository-id .. They are either or.
    KT.hosts.get_synced_content_dropdown().val("");
    activate_select2("#media_select");
};

KT.hosts.on_synced_content_dropdown_change = function() {
    // reset the kickstart-repository-id .. They are either or.
    $("#host_medium_id").val("");
    $("#s2id_host_medium_id").val("");
    $("#hostgroup_medium_id").val("");
    $("#s2id_hostgroup_medium_id").val("");
    activate_select2("#media_select");
};

KT.hosts.set_install_media_bindings = function() {
    // reset the host medium id
    $("#host_medium_id").change(KT.hosts.on_install_media_dropdown_change);
    $("#s2id_host_medium_id").change(KT.hosts.on_install_media_dropdown_change);
    $("#hostgroup_medium_id").change(KT.hosts.on_install_media_dropdown_change);
    $("#s2id_hostgroup_medium_id").change(KT.hosts.on_install_media_dropdown_change);
};

KT.hosts.set_synced_content_bindings = function() {
    KT.hosts.get_synced_content_dropdown().change(KT.hosts.on_synced_content_dropdown_change);
};

KT.hosts.set_media_selection_bindings = function() {
  KT.hosts.set_install_media_bindings();
  KT.hosts.set_synced_content_bindings();
  KT.hosts.get_media_selector_elements().change(KT.hosts.media_selection_changed);
};
