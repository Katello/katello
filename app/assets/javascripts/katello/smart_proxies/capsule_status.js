function loadPulp() {
    var item = $('#pulp-status'),
        version = $('#pulp-version'),
        url = item.data('url');
    $.ajax({
        type: 'get',
        url: url,
        success: function (response) {
            if (response.success) {
                $(document).trigger('GenerateItem', {item: item,
                                                   status: response.success,
                                                   text: _("Active")});
                $(document).trigger('GenerateItem', {item: version,
                                                   status: response.success,
                                                   text: response.message.versions.platform_version});
              } else {
                $(document).trigger('GenerateItem', {item: item,
                                                  status: false,
                                                  text: response.message});
                $(document).trigger('GenerateItem', {item: version,
                                                  status: false,
                                                  text: response.message});
            }
        }
    });
}

$(document).trigger('RegisterLoaderAction', loadPulp);
