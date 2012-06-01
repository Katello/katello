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
        num_columns = 0,
        num_rows = 0;

    var add_row = function(name){
            add_row_header(name);
            $('#grid_content').append(templates.row(num_columns));
        },
        add_row_header = function(name) {
            $('#grid_items').append(templates.row_header(name));
            num_rows += 1;
        },
        add_column = function(name, data) {
            var i;

            add_column_header(name);

            $('.grid_row').each(function(index){
                $(this).append(templates.cell(data[index]));
            })
        },
        add_column_header = function(name) {
            $(templates.column_header(name)).insertBefore('.column_header:last');
            num_columns += 1;
        };

    return {
        add_row             : add_row,
        add_column          : add_column,
        add_column_header   : add_column_header,
        add_row_header      : add_row_header
    }
};

KT.comparison_grid.templates = (function() {
    var cell = function(data) {
            return '<span>' + data + '</span>';
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
        column_header = function(name) {
            var html = '<li class="column_header">';
            html += name;
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
