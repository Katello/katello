var KT = KT ? KT : {};
KT.hosts = {};

$(document).on('ContentLoad', function(){
    KT.hosts.onKatelloHostEditLoad();

    $("#hostgroup_lifecycle_environment_id").change(KT.hosts.fetchContentViews);
    $("#host_lifecycle_environment_id").change(KT.hosts.fetchContentViews);

    $("#hostgroup_content_view_id").change(KT.hosts.contentViewSelected);
    $("#host_content_view_id").change(KT.hosts.contentViewSelected);
    $("#reset_puppet_environment").click(function() {
        KT.hosts.getPuppetEnvironmentSelect().data('content_puppet_match', 'true');
        KT.hosts.setDefaultPuppetEnvironment(KT.hosts.getSelectedContentView(), KT.hosts.getSelectedEnvironment());
    });

});

KT.hosts.fetchContentViews = function () {
    var select = KT.hosts.getContentViewSelect();
    var envId = KT.hosts.getSelectedEnvironment();
    select.find('option').remove();
    if (envId) {
        KT.hosts.signalContentViewFetch(true);
        $.get('/katello/api/v2/content_views/', {environment_id: envId, full_result: true}, function (data) {
            select.find('option').remove();
            select.append($("<option />"));
            $.each(data.results, function(index, view) {
                select.append($("<option />").val(view.id).text(view.name));
            });
            KT.hosts.signalContentViewFetch(false);
        });
    }
};

KT.hosts.signalContentViewFetch = function(fetching) {
    var select = KT.hosts.getContentViewSelect(),
        //parent = select.parent(),
        spinner = $('<img>').attr('src', '/assets/spinner.gif'),
        spinner_id = "content_view_spinner";

    if(fetching) {
        select.hide();
        $(spinner).attr('id', spinner_id).insertAfter(select);
    } else {
        select.show();
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
            select.val(data.id);
            select.trigger('change');
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
    var prefxies = ['host', 'hostgroup'],
        attributes = ['lifecycle_environment_id', 'content_view_id', 'environment_id', 'content_source_id', 'architecture_id', 'operatingsystem_id'];

    $.each(prefxies, function(index, prefix) {
        $.each(attributes, function(attrIndex, attribute) {
            $('#' + prefix + '_' + attribute).live('change', function () {
                KT.hosts.toggle_installation_medium();
            });
        });
    });
    KT.hosts.toggle_installation_medium();
};


KT.hosts.toggle_installation_medium = function() {
    var lifecycle_environment_id, content_source_id, architecture_id, operatingsystem_id, content_view_id;


    if ($('#hostgroup_parent_id').length > 0) {
      lifecycle_environment_id = KT.hosts.getSelectedEnvironment();
      content_view_id = KT.hosts.getSelectedContentView();
      content_source_id = $('#hostgroup_content_source_id').val();
      architecture_id = $('#hostgroup_architecture_id').val();
      operatingsystem_id = $('#hostgroup_operatingsystem_id').val();
    } else {
      lifecycle_environment_id = KT.hosts.getSelectedEnvironment();
      content_view_id = KT.hosts.getSelectedContentView();
      content_source_id = $('#host_content_source_id').val();
      architecture_id = $('#host_architecture_id').val();
      operatingsystem_id = $('#host_operatingsystem_id').val();
    }

    if (content_view_id && lifecycle_environment_id && content_source_id && architecture_id && operatingsystem_id) {
        $.ajax({
            type:'get',
            url: '/operatingsystems/' + operatingsystem_id + '/available_kickstart_repo',
            data: {
                lifecycle_environment_id: lifecycle_environment_id,
                content_source_id: content_source_id,
                architecture_id: architecture_id,
                operatingsystem_id: operatingsystem_id,
                content_view_id: content_view_id
            },
            error: function(jqXHR, status, error){
                KT.hosts.show_medium_selectbox();
            },
            success: function(result){
                if (result == null) {
                    KT.hosts.show_medium_selectbox();
                } else {
                    // add kickstart_url div after checking that it doesn't exist
                    // since this code is called 3 times
                    if ($("#kt_kickstart_url").length == 0) {
                      $('label[for="medium_id"]').after("<div id='kt_kickstart_url' class='col-md-8'></div>");
                    }
                    $("#host_medium_id").hide();
                    $("#hostgroup_medium_id").hide();
                    // populate kickstart_url inside div created above
                    $("#kt_kickstart_url").html(result.name+"<br />"+result.path);
                }
            }
        })
    } else {
        KT.hosts.show_medium_selectbox();
    }

};

KT.hosts.show_medium_selectbox = function() {
    $("#host_medium_id").show();
    $("#hostgroup_medium_id").show();
    $("#kt_kickstart_url").html('');
};
