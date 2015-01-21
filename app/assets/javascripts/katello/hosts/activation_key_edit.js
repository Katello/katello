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

    $("#ak-subscriptions-info").hide();
    $("#ak-subscriptions-spinner").show();

    // Retrieve the activation keys associated with the current
    // environment & content view.
    $.ajax({
        type: 'get',
        url:  foreman_url('/katello/api/v2/environments/' + getSelectedEnvId() + '/activation_keys'),
        data: {'content_view_id': getSelectedContentViewId()},
        success: function(response) {
            KT.hosts.availableActivationKeys = {};
            $.each(response['results'], function (i, key) {
                KT.hosts.availableActivationKeys[key.name] = [];
            });
            ktAkUpdateSubscriptionsInfo();
        },
        error: ktErrorLoadingActivationKeys
    });
}

function ktErrorLoadingActivationKeys(error) {
    $.jnotify("Error while loading activation keys from Katello", { type: "error", sticky: true });
    ktAkUpdateSubscriptionsInfo();
}

function ktFindParamContainer(name){
    var ret;
    $("div#parameters table.row input[ type = 'text']").each(function () {
        var element = $(this);
        if(element.val() == name) {
            ret = element.closest('table.row');
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
  return $("#hostgroup_lifecycle_environment_id").val();
}

function getSelectedContentViewId() {
  return $("#hostgroup_content_view_id").val();
}

function ktSetParam(name, value) {
    var paramContainer = ktFindParamContainer(name);
    if(value) {
        if(! paramContainer) { // we create the param for kt_activation_keys
            $("div#parameters a.btn-success").click();
            paramContainer = $("div#parameters table.row").last();
            paramContainer.find("input").val(name);
        }
        paramContainer.find("textarea").val(value);
    } else if(paramContainer) {
        // we remove the param by setting destroy to 1
        paramContainer.find("input[ type = 'hidden' ]").val(1);
    }
}

function ktParamToAkInput() {
    var paramContainer = ktFindParamContainer(KT.KT_AK_LABEL);
    if(paramContainer) {
        $("#kt_activation_keys").val(paramContainer.find("textarea").val());
    }
}

function ktAkInputToParam() {
    var ktActivationKeysValue = $("#kt_activation_keys").val().replace(/,\s*/g,",").replace(/,$/g,"");
    ktSetParam(KT.KT_AK_LABEL, ktActivationKeysValue);
}

function ktAkUpdateSubscriptionsInfo() {
    var subsInfo = $("ul#ak-subscriptions-info");
    subsInfo.empty();
    var selectedKeys = $("#kt_activation_keys").val().split(/,\s*/);
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
    ktHideParams();
    ktParamToAkInput();
    ktLoadActivationKeys();
}

$(document).on('ContentLoad', function(){

    $("#kt_activation_keys").parents("form").submit(ktAkInputToParam);

    ktOnLoad();

    $("#kt_activation_keys").autocomplete({
        minLength: 0,
        source: function(request, response) {
            var terms = request.term.split(/,\s*/);
            var part = terms.pop();
            var items = [];
            for(key in KT.hosts.availableActivationKeys) {
                if(terms.indexOf(key) == -1) {
                    items.push(key);
                }
            }
            response($.ui.autocomplete.filter(
                items, part));
        },

        focus: function() {
            // prevent value inserted on focus
            return false;
        },
        select: function(event, ui) {
            var oldTerms = this.value.replace(/[^, ][^,]*$/,"");
            this.value = oldTerms + ui.item.value;
            ktAkUpdateSubscriptionsInfo();
            return false;
        },
        close: function() {
            ktAkUpdateSubscriptionsInfo();
        }

    }).bind("focus", function(event) {
        if($(this)[0].value == "") {
     $(this).autocomplete( "search" );
        }});

    $("#hostgroup_lifecycle_environment_id").change(ktLoadActivationKeys);
    $("#hostgroup_content_view_id").change(ktLoadActivationKeys);

    $("#ak_refresh_subscriptions").click(function () {
        ktLoadActivationKeys();
        return false;
    });
});