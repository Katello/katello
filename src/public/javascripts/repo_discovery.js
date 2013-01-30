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
        $(form_id).unbind('submit').submit(function(e){
            e.preventDefault();
            start_discovery();
        });

        $('#new_repos').unbind('click').click(open_subpane);

        $('#url_filter').bind('change, keyup', function(){
            $.uiTableFilter($(list_id), this.value, $(list_id).find("thead > tr:last > th").first().text().trim());
        });

        $(list_id).delegate("input[type=checkbox]", 'change', on_checkbox_change);
        on_checkbox_change();
        init_cancel();
    },
    open_subpane = function(){
        var urls = '?';
        KT.utils.each(selected(), function(element, index){
           if(index > 0) {
               urls += '&';
           }
           urls+= 'urls[]=' + element;
        });
        KT.panel.openSubPanel($(this).data('url') + urls );
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
        var cancel = $(form_id).find('#cancel_discover');
        cancel.unbind('click');
        cancel.click(cancel_discovery);
    },
    draw_url_list = function(url_list){
        var list = $(list_id),
            find_text = function(){ return $(this).find('.hidden-text').html();};
        list.find('.check_icon-black').tipsy('hide');
        KT.initial_repo_discovery.urls = url_list;
        list.find('tbody').html(KT.discovery_templates.url_list(url_list, selected()));
        $('#url_filter').trigger('keyup');

        list.find('.check_icon-black').tipsy({html:true, gravity:'w', className:'content-tipsy',
            title:find_text});
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
        var form = $(form_id),
            cancel = form.find('#cancel_discover');
        form.find('input[type=text]').attr('disabled', 'disabled');
        form.find('input[type=submit]').parent().hide();
        cancel.removeAttr('disabled');
        cancel.parent().show();
    },
    enable_discovery = function(){
        var form = $(form_id);
        form.find('input[type=text]').removeAttr('disabled');
        form.find('input[type=submit]').parent().show();
        form.find('#cancel_discover').parent().hide();
    },
    discovery_started = function() {
        $(list_id).find('tbody').html('<tr><td></td><td></td></tr>');
        $('#url_filter').val('');
        init_updater();
    },
    discovery_ended = function(){
        updater.stop();
        KT.initial_repo_discovery.running = false;
        updater = undefined;
        enable_discovery();
    },
    on_checkbox_change = function(){
        var count = selected().length;
        if(count === 0){
            $('#new_repos').attr('disabled', 'disabled');
        }else {
            $('#new_repos').removeAttr('disabled');
        }
    },
    selected = function(){
        var to_ret = [];
        KT.utils.each($(list_id).find(":checked"), function(element){
            to_ret.push($(element).val());
        });
        return to_ret;
    },
    clear_selections = function(){
        $(list_id).find(":checked").removeAttr('checked');
    };

    return {
        page_load: page_load,
        page_close: page_close,
        clear_selections: clear_selections,
        init_updater: init_updater
    }
})();


KT.discovery_templates = (function(){
    var url_list = function(url_list, selected_list){
        var html = '';

        if(selected_list === undefined){
            selected_list = [];
        }
        if (url_list.length === 0) {
            return '<tr><td></td><td></td></tr>';
        }
        KT.utils.each(url_list, function(elem, index){
            html += url_list_item(elem, selected_list, index % 2 === 0);
        });
        return html;
    },
    url_list_item = function(item, selected_list, odd){
        var selected = '',
            html = '',
            alt = '';
        if (!odd) {
            alt = 'alt';
        }
        if (KT.utils.indexOf(selected_list, item.url) !== -1){
            selected = 'checked';
        }
        html = '<tr class="' + alt + '"><td><label>'
        html += '<input type="checkbox"' + selected + ' value="' + item.url + '"/>' + item.path + '</label>';
        html += '</td>';
        html += '<td>' + existing_tipsy(item.existing) + '</td></tr>';
        return html;
    },
    existing_tipsy = function(existing_hash){
        var html = '';
        if (KT.utils.isEmpty(existing_hash)) {
            return html;
        }

        html += '<span class="grid_3"><span class="check_icon-black">';
        html += '<span class="hidden-text hidden"><span class="repo_tipsy la">';
        html += i18n.existing_repos_found + '<ul>';
        KT.utils.each(existing_hash, function(repo_list, product_name){
            html += existing_product(product_name, repo_list);
        });

        html += '</ul></span></span></span></span>';
        return html;
    },
    existing_product = function(product_name, repo_list){
        var html = '<li class="product_item">' + product_name + '<ul class="repo_list">';
        KT.utils.each(repo_list, function(repo_name){
           html += '<li class="repo_item">' + repo_name + '</li>';
        });

        return html + '</ul></li>';
    };

    return {
        url_list:url_list
    }

})();


KT.repo_discovery.new_page = (function(){
    var panel_id = '#repo_creation',
        product_select_id = "#existing_product_select",
        form_id = '#discovered_creation',
        product_details = '#product_details';


    var init_panel = function(){
        $(product_select_id).chosen();
        $(panel_id).find('input[type=radio]').change(radio_change);
        $(form_id).submit(submit_form);
        $(window).unbind('repo.create');
        $(window).bind('repo.create', create_repos);
    },
    submit_form = function(event) {
        event.preventDefault();
        var form = $(form_id),
            product_details = form.find('#product_details'),
            product_id, name, label, provider_id;

        disable_form();

        if (product_details.find('input[type=radio]:checked').val() == 'true'){
            name = product_details.find('input[type=text][name=product_name]').val();
            label = product_details.find('input[type=text][name=product_label]').val();
            create_product(name, label, $('#new_product').data('url'));
        }
        else {
            product_id = $(product_select_id).val();
            initiate_repo_creation(product_id);
        }

    },
    initiate_repo_creation = function(product_id) {
        var repos = [],
            provider_id = $(form_id).data('provider_id'),
            create_url = KT.routes.provider_product_repositories_path(provider_id, product_id);

        KT.utils.each($('.new_repo'), function(repo_div){
            repo_div = $(repo_div);
            var name = repo_div.find('.name_input').val(),
                label = repo_div.find('.label_input').val(),
                url = repo_div.find('input[type=hidden]').val(),
                id = '#' + repo_div.attr('id');
            repos.push({name:name, label:label, feed:url, id:id})
        });
        $(window).trigger('repo.create', [create_url, repos]);
    },
    create_product = function(name, label, create_url){
        $.ajax({
            url:create_url,
            type: 'POST',
            data: {product:{name:name, label:label}},
            success: function(data){
                var product_div = $('#new_product');
                product_div.find('.name_input').replaceWith(name);
                product_div.find('.label_input').replaceWith(label);
                initiate_repo_creation(data.id);
            },
            error: function(){
                enable_form();
            }
        });
    },
    create_repos = function(event, create_url, repo_list){
        var repo = repo_list.shift();

        $.ajax({
            url:create_url,
            type: 'POST',
            data: {'repo':repo, 'ignore_success_notice':true},
            success:function(){
                var repo_div = $(repo.id),
                    created_num, created_msg;
                repo_div.removeClass('new_repo').addClass('created_repo');
                repo_div.find('.name_input').replaceWith(repo.name);
                repo_div.find('.label_input').replaceWith(repo.label);

                if (repo_list.length !== 0){
                    $(window).trigger('repo.create', [create_url, repo_list]);
                }
                else {
                    KT.repo_discovery.clear_selections();
                    KT.repo_discovery.init_updater();

                    created_num = $('.created_repo').length;
                    if (created_num === 1) {
                        created_msg = i18n.discovery_success_one
                    }
                    else{
                        created_msg = i18n.discovery_success_multi(created_num)
                    }

                    KT.panel.closeSubPanel($('#subpanel'));
                    notices.displayNotice('success', JSON.stringify({notices:[created_msg]}),
                                            'repositories___create');

                }
            },
            error: function(){
                enable_form();
            }
        });


    },
    disable_form = function(){
        $(form_id).find('input').attr('disabled', 'disabled');
        $(product_select_id).attr('disabled', true).trigger("liszt:updated");
    },
    enable_form = function(){
        $(form_id).find('input').removeAttr('disabled');
        $(product_select_id).attr('disabled', false).trigger("liszt:updated");
    },
    radio_change = function(){
        if ($(this).val() === 'true'){
            $(product_select_id).attr('disabled', true).trigger("liszt:updated");
            $('#new_product').show();
        }
        else {
            $(product_select_id).attr('disabled', false).trigger("liszt:updated");
            $('#new_product').hide();
        }
    };



    return {
        init_panel:init_panel
    }
})();