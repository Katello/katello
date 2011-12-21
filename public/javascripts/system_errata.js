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
    var system_errata_container = $('#system_errata'),
    	system_id = system_errata_container.data('system_id'),
    	table_body = system_errata_container.find('tbody'),
    	load_more = $('#load_more_errata'),
        task_list = {},
    		
    	init = function(){
    		register_events();
    	},
    	register_events = function(){
    		$('#display_errata_type').live('change', filter_errata);
    		$('#select_all_errata').live('change', select_all_errata);
    		$('#errata_state_radio_applied').live('change', filter_errata);
    		$('#errata_state_radio_outstanding').live('change', filter_errata);
            $('#run_errata_button').live('click', add_errata);
    		load_more.live('click', get_errata);
    	},
    	filter_errata = function(event){
    		var type = get_current_filter(),
    			state = get_current_state();
    		
    		insert_data([], false);
    		show_spinner(true);
    		
			$.ajax({
    			method	: 'get',
    			url		: KT.routes.items_system_errata_path(system_id),
    			data	: { filter_type : type, offset : 0, errata_state : state },
    		}).success(function(data){
    			insert_data(data, false);
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
    	get_errata = function(){
    		var offset = $('#loaded_summary').data('current_count'),
    			value = get_current_filter();
    		
    		$.ajax({
    			method	: 'get',
    			url		: KT.routes.items_system_errata_path(system_id),
    			data	: { filter_type : value, offset : offset },
    		}).success(function(data){
    			insert_data(data, true);
    			update_counts();
    		});
    	},
        add_errata = function(){
            var selected_errata = $('#system_errata').find(':checkbox:checked'),
                errata_ids = [],
                params = {};

            $.each(selected_errata, function(index, value){
                set_status($(value).parent().parent(), 'installing');
                errata_ids.push($(value).val());
            });

            params["errata_ids"] = errata_ids;
            params = $.param(params);

            $.ajax({
                url : KT.routes.install_system_errata_path(system_id),
                type : 'POST',
                data : params
            }).success(function(data){
                task_list[data] = errata_ids;
                set_errata_finished(errata_ids);
            });
        },
        set_errata_finished = function(errata_ids){
            var i = 0, 
                length = errata_ids.length,
                errata = [];

            for( i; i < length; i += 1){
                errata = $('#system_errata_' + KT.common.escapeId(errata_ids[i]));
                set_status(errata, 'finished');
            }
        },
    	insert_data = function(html, append){
    		if( append ){
    			table_body.append(html);
    		} else {
    			table_body.html(html);
    		}
    		update_counts();
    	},
    	update_counts = function(){
    		var current_count = table_body.find('tr').length,
    			total_count = $('#loaded_summary').data('total');
    		
    		$('#loaded_summary').data('current_count', current_count);
    		$('#loaded_summary').html(i18n.x_of_y_errata(current_count, total_count));
    		
    		if( current_count === total_count ){
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
        set_status = function(errata_row, status){
            if( status === 'installing' ){
                errata_row.find('.errata_status_text').html(i18n.errata_installing);
                errata_row.find('img').show();
            } else if( status === 'finished' ){
                errata_row.find('img').hide();
                errata_row.find('.errata_status_text').html(i18n.errata_install_finished);
            }
            errata_row.find('.errata_status').show();
        };
	    
    return {
        init	: init
    };
    
}();

$(document).ready(function() {
    KT.system.errata.init();
});
