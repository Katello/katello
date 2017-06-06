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

KT.system = KT.system || {};

KT.system.errata = function() {
    var errata_container,
        table_body,
        load_more,
        task_list = {},
        actions_updater,
        parent_id,  // e.g. system id, system group id
        items_url,
        install_url,
        status_url,
        errata_for,
        update_function,

        init = function(editable, page){
            errata_container = $('#errata_container');
            table_body = errata_container.find('tbody');
            load_more = $('#load_more_errata');

            // This component is shared by the systems and system groups pages; however, some of the behavior is
            // different depending on the page.  For example, the URLs to interact with the server.
            errata_for = page;
            parent_id = errata_container.data('parent_id');
            if (page === 'system') {
                items_url = KT.routes.items_system_errata_path(parent_id);
                install_url = KT.routes.install_system_errata_path(parent_id);
                status_url = KT.routes.status_system_errata_path(parent_id);
                update_function = update_status_for_system;
                KT.tipsy.custom.tooltip($('.tipsy-icon.errata-info'));
            } else {
                // errata_for === 'system_group'
                items_url = KT.routes.items_system_group_errata_path(parent_id);
                install_url = KT.routes.install_system_group_errata_path(parent_id);
                status_url = KT.routes.status_system_group_errata_path(parent_id);
                update_function = update_status_for_group;
                KT.tipsy.custom.tooltip($('.tipsy-icon.systems, .tipsy-icon.errata-info'));
            }

            register_events();

            // Not all users have permission to interact with errata; those that don't
            // cannot check their status either.
            if(editable) {
                init_status_check();
            }
            show_spinner(true);
            fetch_errata({ data : { clear_items : false }});
        },
        register_events = function(){
            $('#display_errata_type').bind('change', { clear_items : true }, fetch_errata);
            $('#select_all_errata').bind('change', select_all_errata);
            $('#errata_state_radio_applied').bind('change', fetch_errata);
            $('#errata_state_radio_outstanding').bind('change', fetch_errata);
        $('#run_errata_button').bind('click', add_errata);
        $('#select_all_button').bind('click', select_all);
        $('#deselect_all_button').bind('click', deselect_all);
            load_more.bind('click', { clear_items : false }, fetch_errata);
        },
        init_status_check = function(){
            var timeout = 8000;

            actions_updater = $.PeriodicalUpdater(status_url, {
                method: 'get',
                type: 'json',
                data: function() {return {id: Object.keys(task_list)};},
                global: false,
                minTimeout: timeout,
                maxTimeout: timeout
            }, update_function);
        },
        fetch_errata = function(event){
            var type = get_current_filter(),
                state = get_current_state(),
                offset,
                clear_items = event.data ? event.data.clear_items : false;

            if( clear_items ){
                insert_data({ "html" : "", "results_count" : 0, "total_count" : 0, "current_count" : 0}, false);
                show_spinner(true);
            }

            offset = clear_items ? 0 : $('#loaded_summary').data('current_count');

            $.ajax({
                method    : 'get',
                url        : items_url,
                data    : { filter_type : type, offset : offset, errata_state : state }
            }).success(function(data){
                insert_data(data, !clear_items);
                show_spinner(false);
            });
        },
        get_current_filter = function(){
            return $('#display_errata_type').val();
        },
        get_current_state = function(){
            return $('input[@name=errata_state_radio]:checked').val();
        },
        select_all_errata = function(){
            var checkboxes = table_body.find(':checkbox');

            if( $('#select_all_errata').attr('checked') ){
                checkboxes.attr('checked', true);
            } else {
                checkboxes.attr('checked', false);
            }
        },
        select_all = function(){
            var checkboxes = table_body.find(':checkbox');
            checkboxes.attr('checked', true);
        },
        deselect_all = function(){
            var checkboxes = table_body.find(':checkbox');
            checkboxes.attr('checked', false);
        },
        add_errata = function(){
            var selected_errata = errata_container.find(':checkbox:checked'),
                errata_ids = [],
                params = {};

            if ($('#run_errata_button').hasClass("disabled") || selected_errata.length === 0){
                return;
            }

            $.each(selected_errata, function(index, value){
                errata_ids.push($(value).val());
            });

            set_status(errata_ids, 'installing');

            params["errata_ids"] = errata_ids;
            params = $.param(params);

            $.ajax({
                url : install_url,
                type : 'POST',
                data : params
            }).success(function(data){
                if( Object.keys(task_list).length === 0 ){
                    actions_updater.restart();
                }
                task_list[data] = errata_ids;
                if(errata_for === 'system') {
                    set_status(errata_ids, 'installing', undefined);
                } else {
                    set_status(errata_ids, 'installing', KT.routes.system_group_event_path(parent_id, data));
                }
            });
        },
        update_status_for_system = function(data){
            var i = 0, length = data.length, task, url;

            for(i; i < length; i += 1){
                task = data[i];
                url = KT.routes.system_event_path(parent_id, task.id);

                if( task['state'] === 'finished' ){
                    set_status(task_list[task['id']], 'finished', url);
                    delete task_list[task['id']];
                } else if( task['state'] === 'running' ){
                    if( !task_list.hasOwnProperty(task['id']) ){
                        task_list[task['id']] = task['parameters']['errata_ids'];
                        set_status(task['parameters']['errata_ids'], 'installing', url);
                    }
                } else if( task['state'] === 'error' ){
                    set_status(task_list[task['id']], 'failed', url);
                    delete task_list[task['id']];
                }
            }

            if( Object.keys(task_list).length === 0 ){
                actions_updater.stop();
            }
        },
        update_status_for_group = function(data){
            var i = 0, num_jobs = data.length, job, num_tasks, task, url;

            for(i; i < num_jobs; i += 1){
                job = data[i];
                num_tasks = job.tasks.length;
                url = KT.routes.system_group_event_path(parent_id, job.id);

                var j = 0, running = 0, error = 0;
                for(j; j < num_tasks; j += 1){
                    task = job.tasks[j];
                    if ((task.state === 'waiting') || (task.state === 'running')) {
                        running += 1;
                    } else if (task.state === 'error') {
                        error += 1;
                    }
                }
                if (running > 0) {
                    // still have a task running... status should remain installing
                    if( !task_list.hasOwnProperty(job.id) ){
                        task_list[job.id] = job['parameters']['errata_ids'];
                        set_status(task_list[job.id], 'installing', url);
                    }
                } else if (error > 0) {
                    // no tasks are still running, but at least 1 error was encountered
                    set_status(task_list[job.id], 'failed', url);
                    delete task_list[job.id];
                } else {
                    // looks like all tasks completed...
                    set_status(task_list[job.id], 'finished', url);
                    delete task_list[job.id];
                }
            }

            if( Object.keys(task_list).length === 0 ){
                actions_updater.stop();
            }
        },
        insert_data = function(data, append){
            var html = data["html"];

            if(data.total_count > 0){
                $('#run_errata_button').removeClass("disabled");
            }
            if( append ){
                table_body.append(html);
            } else {
                table_body.html(html);
            }
            update_counts(data);
        },
        update_counts = function(data){
            var current_count = data["current_count"],
                total_count = data["total_count"],
                results_count = data["results_count"];

            $('#loaded_summary').data('current_count', current_count),
            $('#loaded_summary').html(i18n.x_of_y_total(current_count, results_count, total_count));

            if( current_count === results_count ){
                load_more.hide();
            } else {
                load_more.show();
            }
        },
        show_spinner = function(show){
            if( show ){
                $('#list-spinner').show();
            } else {
                $('#list-spinner').hide();
            }
        },
        set_status = function(errata_ids, status, url){
            var rows = get_rows(errata_ids),
                errata_row, i, length;

            length = rows.length;

            for( i = 0; i < length; i += 1){
                errata_row = rows[i];

                if( status === 'installing' ){
                    errata_row.find('.errata_status_text').html(get_status_block(i18n.installing, url));
                    errata_row.find('img').show();
                } else if( status === 'finished' ){
                    errata_row.find('img').hide();
                    errata_row.find('.errata_status_text').html(get_status_block(i18n.install_finished, url));
                } else if ( status === 'failed' ) {
                    errata_row.find('img').hide();
                    errata_row.find('.errata_status_text').html(get_status_block(i18n.install_error, url));
                }
                errata_row.find('.errata_status').show();
            }
        },
        get_status_block = function(status, url){
            if(url === undefined) {
                return status;
            } else {
                var html = '<a data-url="' + url + '" class="subpanel_element">' + status + '</a>';
                return html;
            }
        },
        get_rows = function(errata_ids){
            var i = 0,
                length = errata_ids.length,
                rows = [];

            for( i; i < length; i += 1){
                rows.push($('#errata_' + KT.common.escapeId(errata_ids[i])));
            }

            return rows;
        };

    return {
        init    : init
    };

}();

// Call this init() from a location where the 'editable' flag can be set
// appropriately. In this case it is called from errata/_index.html.haml
//$(document).ready(function() {
//    KT.system.errata.init(editable);
//});
