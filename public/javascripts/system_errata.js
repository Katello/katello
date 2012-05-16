/**
 Copyright 2011 Red Hat, Inc.

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
    var system_errata_container = undefined,
        system_id = undefined,
        table_body = undefined,
        load_more = undefined,
        task_list = {},
        actions_updater,
        init = function(editable){
            system_errata_container = $('#system_errata');
            system_id = system_errata_container.data('system_id');
            table_body = system_errata_container.find('tbody');
            load_more = $('#load_more_errata');

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
    		load_more.bind('click', { clear_items : false }, fetch_errata);
            KT.tipsy.custom.errata_tooltip();
    	},
        init_status_check = function(){
            var timeout = 8000;

            actions_updater = $.PeriodicalUpdater(KT.routes.status_system_errata_path(system_id), {
                method: 'get',
                type: 'json',
                data: function() {return {uuid: Object.keys(task_list)};},
                global: false,
                minTimeout: timeout,
                maxTimeout: timeout
            }, update_status);
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
    			method	: 'get',
    			url		: KT.routes.items_system_errata_path(system_id),
    			data	: { filter_type : type, offset : offset, errata_state : state }
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
        add_errata = function(){
            var selected_errata = $('#system_errata').find(':checkbox:checked'),
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
                url : KT.routes.install_system_errata_path(system_id),
                type : 'POST',
                data : params
            }).success(function(data){
                if( Object.keys(task_list).length === 0 ){
                    actions_updater.restart();
                }
                task_list[data] = errata_ids;
            });
        },
        update_status = function(data){
            var i = 0, length = data.length,
                task;

            for(i; i < length; i += 1){
                task = data[i];
                if( task['state'] === 'finished' ){
                    set_status(task_list[task['uuid']], 'finished');
                    delete task_list[task['uuid']];
                } else if( task['state'] === 'running' ){
                    if( !task_list.hasOwnProperty(task['uuid']) ){
                        task_list[task['uuid']] = task['parameters']['errata_ids'];
                        set_status(task['parameters']['errata_ids'], 'installing');
                    }
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
    		$('#loaded_summary').html(i18n.x_of_y_errata(current_count, results_count, total_count));
    		
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
        set_status = function(errata_ids, status){
            var rows = get_rows(errata_ids),
                errata_row, i, length;
            
            length = rows.length;

            for( i = 0; i < length; i += 1){
                errata_row = rows[i];

                if( status === 'installing' ){
                    errata_row.find('.errata_status_text').html(i18n.errata_installing);
                    errata_row.find('img').show();
                } else if( status === 'finished' ){
                    errata_row.find('img').hide();
                    errata_row.find('.errata_status_text').html(i18n.errata_install_finished);
                }
                errata_row.find('.errata_status').show();
            }
        },
        get_rows = function(errata_ids){
            var i = 0, 
                length = errata_ids.length,
                rows = [];

            for( i; i < length; i += 1){
                rows.push($('#system_errata_' + KT.common.escapeId(errata_ids[i])));
            }

            return rows;
        };
	    
    return {
        init	: init
    };
    
}();

// Call this init() from a location where the 'editable' flag can be set
// appropriately. In this case it is called from errata/_index.html.haml
//$(document).ready(function() {
//    KT.system.errata.init(editable);
//});
