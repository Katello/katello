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

KT.comparison_grid = function(){
    var templates = KT.comparison_grid.templates,
        utils = KT.utils,
        columns = {},
        num_columns_shown = 0,
        num_rows = 0;

    var add_row = function(name){
            add_row_header(name);
            $('#grid_content').append(templates.row(num_columns_shown));
            num_rows += 1;
        },
        add_row_header = function(name) {
            $('#grid_items').append(templates.row_header(name));
        },
        add_column = function(id, to_display, previous_column_id, data) {
            var i, column;

            add_column_header(id, to_display);
            columns[id] = { 'id' : id, 'to_display' : to_display, 'data' : data };
        },
        add_column_header = function(id, to_display) {
            $(templates.column_header(id, to_display)).insertBefore('.column_header:last');
        },
        add_columns = function(data){
            var i,
                length = data.length;

            for(i = 0; i < length; i += 1){
                add_column(data[i]['id'], data[i]['name']);
            }
        },
        show_columns = function(data){
            var i, id,
                length = data.length;

            num_columns_shown = 0;

            utils.each(columns, function(value, key){
                if( data[key] ){
                    $('#column_' + key).show();
                    num_columns_shown += 1;
                } else {
                    $('#column_' + key).hide();
                }
            });
        };

    return {
        add_row             : add_row,
        add_row_header      : add_row_header,
        add_column          : add_column,
        add_columns         : add_columns,
        add_column_header   : add_column_header,
        show_columns        : show_columns
    }
};

KT.comparison_grid.templates = (function() {
    var cell = function(data) {
            data = data === undefined ? "" : data;
            return '<span class="grid_cell">' + data + '</span>';
        },
        row = function(num_columns) {
            var i,
                html ='<div class="grid_row">';

            for(i = 0; i < num_columns; i += 1){
                html += cell(i);
            }
            html += '</div>';            

            return html;
        },
        row_header = function(name) {
            var html = '<li class="row_header">';
            html += name;
            html += '</li>';
            return html;
        },
        column = function() {
        },
        column_header = function(id, to_display) {
            var html = '<li data-id="' + id  + '" id="column_' + id + '" class="column_header hidden">';
            html += to_display;
            html += '</li>';
            return html;
        };

    return {
        cell            : cell,
        row             : row,
        column_header   : column_header,
        row_header      : row_header
    }
})();
