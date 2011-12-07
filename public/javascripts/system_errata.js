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
    		
    	init = function(){
    		register_events();
    	},
    	register_events = function(){
    		$('#display_errata_type').live('change', filter_errata_by_type);
    		$('#select_all_errata').live('change', select_all_errata);
    	},
    	filter_errata_by_type = function(data){
    		var value = data.currentTarget.value;
    		
    		$.ajax({
    			method	: 'get',
    			url		: KT.routes.items_system_errata_path(system_id),
    			data	: { filter_type : value, offset : 0 },
    		}).success(function(data){
    			insert_data(data, false);
    		});
    	},
    	select_all_errata = function(){
    		var checkboxes = table_body.find(':checkbox');
    		
    		if( $('#select_all_errata').attr('checked') ){
    			checkboxes.attr('checked', true);	
    		} else {
    			checkboxes.attr('checked', false);
    		}
    	},
    	insert_data = function(html, append){
    		if( append ){
    			table_body.append(html);
    		} else {
    			table_body.html(html);
    		}
    	};
	    
    return {
        init	: init,
    };
    
}();

$(document).ready(function() {
    KT.system.errata.init();
});