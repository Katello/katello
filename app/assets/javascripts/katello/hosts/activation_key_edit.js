var KT = KT ? KT : {};
KT.hosts = KT.hosts  || {};

KT.KT_AK_LABEL = 'kt_activation_keys';
KT.hosts.availableActivationKeys = {};

function ktLoadActivationKeys() {
    if(getSelectedEnvId() && getSelectedContentViewId()) {
        ktAkTab().show();
    } else {
        ktAkTab().hide();
        return; //no Katello-specific env selected
    }

    $("#ak-load-error").hide();
    $("#ak-subscriptions-info").hide();
    $("#ak-subscriptions-spinner").show();

    // Retrieve the activation keys associated with the current
    // environment & content view.
    $.ajax({
        type: 'get',
        url:  tfm.tools.foremanUrl('/katello/api/v2/environments/' + getSelectedEnvId() + '/activation_keys'),
        data: {'content_view_id': getSelectedContentViewId()},
        success: function(response) {
            KT.hosts.availableActivationKeys = {};
            $.each(response['results'], function (i, key) {
                KT.hosts.availableActivationKeys[key.name] = [];
            });
            tfm.typeAheadSelect.updateOptions(Object.keys(KT.hosts.availableActivationKeys), KT.KT_AK_LABEL);
        },
        error: function() {
          $("#ak-load-error").show();
        },
    });
}

function ktFindParamContainer(name){
    var ret;
    $("div#parameters .fields input[ type = 'text']").each(function () {
        var element = $(this);
        if(element.val() == name) {
            ret = element.closest('.fields');
            return false;
        }
        return true;
    });
    return ret;
}

function ktHideParams() {
    var param = ktFindParamContainer(KT.KT_AK_LABEL);
    if(param) {
        param.hide();
    }
}

function getSelectedEnvId() {
    var dataId = $("#hostgroup_lifecycle_environment_id > option:selected").data("id");
    if (dataId === undefined) {
        dataId = $("#hostgroup_lifecycle_environment_id").val();
    }
    return dataId;
}

function getSelectedContentViewId() {
    var dataId = $("#hostgroup_content_view_id > option:selected").data("id");
    if (dataId === undefined) {
        dataId = $("#hostgroup_content_view_id").val();
    }
    return dataId;
}

function ktSetParam(name, value) {
    var paramContainer = ktFindParamContainer(name);
    if(value) {
        if(! paramContainer) { // we create the param for kt_activation_keys
            var addParameterButton = $('#parameters').find('.btn-primary');
            addParameterButton.click();
            var directionOfAddedItems = addParameterButton.attr('direction');
            var paramContainer = $('#parameters').find('.fields');
            if(directionOfAddedItems === 'append'){
                paramContainer = paramContainer.last();
            } else {
                paramContainer = paramContainer.first();
            }
            paramContainer.find("input[name*='name']").val(name);
        }
        paramContainer.find("textarea").val(value);
        paramContainer.find("input[ type = 'hidden' ]").val(0);
    } else if(paramContainer) {
        // we remove the param by setting destroy to 1
        paramContainer.find("input[ type = 'hidden' ]").val(1);
    }
}

function ktAkGetKeysFromParam() {
    var paramContainer = ktFindParamContainer(KT.KT_AK_LABEL);
    var keys = [];
    if(paramContainer) {
        keys = paramContainer.find("textarea").val().split(',').map(function(key) {
          return key.trim();
        });
    }
    return keys;
}

function ktAkUpdateSubscriptionsInfo(selectedKeys) {
    var subsInfo = $("ul#ak-subscriptions-info");
    subsInfo.empty();
    $.each(selectedKeys, function(i, key) {
      if(KT.hosts.availableActivationKeys[key]) {
        // hack to make it working with deface
        var ul = "<ul>", ul_end = "</ul>", li = "<li>", li_end = "</li>";
        content = li + key + ul;
        if(!KT.hosts.availableActivationKeys[key].length == 0) {
            content += li;
            content += KT.hosts.availableActivationKeys[key].join(li_end + li);
            content += li_end;
        }
        content +=  ul_end + li_end;
        subsInfo.append(content);
      }
    });
    $("#ak-subscriptions-info").show();
    $("#ak-subscriptions-spinner").hide();
}

function ktAkTab() {
    return $('li#activation_keys_tab');
}

function ktOnLoad() {
    tfm.store.observeStore('typeAheadSelect', function(items, unsubscribe) {
        if (items.kt_activation_keys) { // Wait until after initialization to subscribe to store changes
            unsubscribe();

            tfm.typeAheadSelect.updateSelected(ktAkGetKeysFromParam(), KT.KT_AK_LABEL);

            tfm.store.observeStore('typeAheadSelect', function(items) {
                if (items.kt_activation_keys) {
                    var selected = items.kt_activation_keys.selected || [];

                    ktAkUpdateSubscriptionsInfo(selected);
                    ktSetParam(KT.KT_AK_LABEL, selected.map(function(key) {
                      return key.trim();
                    }).join(','));
                }
            });
        }
    });

    ktHideParams();
    ktLoadActivationKeys();
}

$(document).on('ContentLoad', function(){
    ktOnLoad();

    $("#hostgroup_lifecycle_environment_id").change(ktLoadActivationKeys);
    $("#hostgroup_content_view_id").change(ktLoadActivationKeys);

    $("#ak_refresh_subscriptions").click(function () {
        ktLoadActivationKeys();
        return false;
    });
});
