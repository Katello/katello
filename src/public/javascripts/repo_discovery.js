/**
 Copyright 2012 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/



KT.repo_discovery = (function(){
    var updater = undefined,
        form_id = '#repo_discovery_form',
        list_id = '#discovered_repos';

    var page_load = function(){
        draw_url_list(KT.initial_repo_discovery.urls);
        if(KT.initial_repo_discovery.running){
            discovery_started();
            disable_discovery();
        }
        $(form_id).submit(function(e){
            e.preventDefault();
            start_discovery();
        });
        init_cancel();
    },
    page_close = function(){
        if(updater !== undefined){
            updater.stop();
            updater = undefined;
        }
    },
    init_updater = function(){
        var url = $(list_id).data('url');
        if(updater !== undefined){
            return;
        }
        updater = $.PeriodicalUpdater(url, {
              method: 'get',
              type: 'json',
              global: 'false'
            },
            function(data, success) {
                if(data !== '') { //403
                    draw_url_list(data.urls);
                    if(!data.running){
                        discovery_ended();
                    }
                }
            });
    },
    init_cancel = function(){
        $(form_id).find('#cancel_discover').click(cancel_discovery);
    },
    draw_url_list = function(url_list){
        KT.initial_repo_discovery.urls = url_list;
        $('#discovered_repos').html(KT.discovery_templates.url_list(url_list));
    },
    start_discovery = function(){
        var form = $(form_id),
            discover_url = form.find('input[type=text]').val();
        disable_discovery();
        $.ajax({
            contentType:"application/json",
            type: "POST",
            url: form.data('url'),
            data: JSON.stringify({'url':discover_url}),
            cache: false,
            success: function(data) {
                discovery_started();
            },
            error: function(data) {
                enable_discovery();
            }
        });
        draw_url_list([]);
    },
    cancel_discovery = function(){
        var button = $(form_id).find('#cancel_discover');
        button.attr('disabled', 'disabled');
        $.ajax({
            contentType:"application/json",
            type: "POST",
            url: button.data('url'),
            cache: false,
            success: function(data) {
            },
            error: function(data) {
                button.removeAttr('disabled');
            }
        });

    },
    disable_discovery = function(){
        var form = $(form_id);
        form.find('input[type=text]').attr('disabled', 'disabled');
        form.find('input[type=submit]').parent().hide();
        form.find('#cancel_discover').removeAttr('disabled');
        form.find('#cancel_discover').parent().show();
    },
    enable_discovery = function(){
        var form = $(form_id);
        form.find('input[type=text]').removeAttr('disabled');
        form.find('input[type=submit]').parent().show();
        form.find('#cancel_discover').parent().hide();
    },
    discovery_started = function() {
        init_updater();

    },
    discovery_ended = function(){
        updater.stop();
        KT.initial_repo_discovery.running = false;
        updater = undefined;
        enable_discovery();
    };

    return {
        page_load: page_load,
        page_close: page_close
    }
})();


KT.discovery_templates = (function(){


    var url_list = function(url_list){
        var html = '<table>';
        KT.utils.each(url_list, function(elem){
            html += url_list_item(elem);
        });
        html += '</table>';
        return html;
    },
    url_list_item = function(item){
        var html = '<tr><td>' + item.url + '</td></tr>';
        return html;
    };

    return {
        url_list:url_list
    }

})();