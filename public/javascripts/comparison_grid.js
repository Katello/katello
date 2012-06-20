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
        controls,
        columns = {},
        num_columns_shown = 0,
        num_rows = 0,
        grid_row_headers_el,
        grid_content_el,
        max_visible_columns = 5;

    var init = function(){
            events = KT.comparison_grid.events(this).init();
            controls = KT.comparison_grid.controls(this);
            grid_row_headers_el = $('#grid_row_headers');
            grid_content_el = $('#grid_content');
        },
        add_row = function(id, name, cell_data, parent_id){
            var cells = [], display,
                i = 0, length = utils.size(columns),
                row_level = parent_id ? 2 : 1,
                cell_columns = KT.utils.keys(cell_data);
            
            for(col in columns){
                in_column = utils.include(cell_columns, col) ? true : false;
                
                if( in_column ){
                    cells.push({ 'in_column' : in_column, 'display' : cell_data[col]['display'], 'id' : col, 'hover' : cell_data[col]['hover'] });
                } else {
                    cells.push({ 'in_column' : in_column, 'id' : col });
                }
            }

            add_row_header(id, name, parent_id, row_level);

            if( parent_id ){
                grid_content_el.find('#grid_row_' + parent_id).after(templates.row(id, utils.size(columns), cells, row_level));
            } else {
                grid_content_el.append(templates.row(id, utils.size(columns), cells, row_level));
            }
            
            num_rows += 1;
        },
        add_row_header = function(id, name, parent_id, row_level) {
            if( parent_id ){
                grid_row_headers_el.find('#row_header_' + parent_id).after(templates.row_header(id, name, row_level));
            } else {
                grid_row_headers_el.append(templates.row_header(id, name, row_level));
            }
        },
        add_rows = function(data, append) {
            var i = 0, length = data.length;

            append = (append === undefined) ? true : append;

            if( !append ){
                grid_content_el.html("");
                grid_row_headers_el.html("");
            }

            for(i = 0; i < length; i++){
                add_row(data[i]['id'], data[i]['name'], data[i]['cols'], data[i]['parent_id']);
            }

            for(col in columns){
                if( columns.hasOwnProperty(col) ){
                    if( columns[col]['shown'] ){
                        $('.cell_' + col).show();
                    } else {
                        $('.cell_' + col).hide();
                    }
                }
            }
            
            $('.grid_row').css('width', utils.size(columns) * 100);
        },
        add_column = function(id, to_display, previous_column_id, data) {
            var i, column;

            add_column_header(id, to_display);
            columns[id] = { 'id' : id, 'to_display' : to_display, 'data' : data };
        },
        add_column_header = function(id, to_display) {
            var column_headers = $('#column_headers');

            column_headers.append(templates.column_header(id, to_display));
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
                    $('#column_headers').width($('#column_headers').width() + 100);
                    $('#column_' + key).show();
                    columns[key]['shown'] = true;
                    num_columns_shown += 1;
                    $('.cell_' + key).show();
                } else {
                    columns[key]['shown'] = false;
                    $('#column_' + key).hide();
                    $('.cell_' + key).hide();
                }
            });

            if( num_columns_shown > max_visible_columns ){
                controls.horizontal_scroll.show();            
                $('#column_headers_window').width(100 * max_visible_columns);
            } else {
                controls.horizontal_scroll.hide();
                $('#column_headers_window').width(num_columns_shown * 100);
            }
        };

    return {
        init                    : init,
        add_row                 : add_row,
        add_rows                : add_rows,
        add_row_header          : add_row_header,
        add_column              : add_column,
        add_columns             : add_columns,
        add_column_header       : add_column_header,
        show_columns            : show_columns,
        get_num_columns_shown   : function(){ return num_columns_shown; },
        get_max_visible_columns : function(){ return max_visible_columns; }
    }
};

KT.comparison_grid.controls = function(grid) {
    var horizontal_scroll = (function() {
            var right_arrow = $('#right_slide_arrow'),
                right_arrow_trigger = right_arrow.find('.slide_trigger'),
                left_arrow  = $('#left_slide_arrow'),
                left_arrow_trigger = left_arrow.find('.slide_trigger'),

                show = function() {
                    right_arrow.show();
                    left_arrow.show();
                },
                hide = function() {
                    right_arrow.hide();
                    left_arrow.hide();
                },
                set_arrow_states = function() {
                    var current_position = $('#column_headers').position().left,
                        stop_position = -((grid.get_num_columns_shown() - grid.get_max_visible_columns()) * 100);
                    
                    if( current_position === 0 ){
                        right_arrow.find('span').addClass('disabled');
                        left_arrow.find('span').removeClass('disabled');
                    } else if( stop_position === current_position ) {
                        left_arrow.find('span').addClass('disabled');
                        right_arrow.find('span').removeClass('disabled');
                    } else {
                        right_arrow.find('span').removeClass('disabled');
                        left_arrow.find('span').removeClass('disabled');
                    }
                },
                slide_left = function() {
                    var position = '-=100',
                        current_position = $('#column_headers').position().left,
                        stop_position = -((grid.get_num_columns_shown() - grid.get_max_visible_columns()) * 100);
                    
                    if( stop_position < current_position && current_position <= 0 ){
                        left_arrow.find('span').addClass('disabled');
                        $('#grid_content').animate({ 'left' : position }, 'slow');
                        $('#column_headers').animate({ 'left' : position }, 'slow',
                            function() {
                                left_arrow.find('span').removeClass('disabled');
                                set_arrow_states();
                                left_arrow.trigger('mouseover');
                            }
                        );
                    }
                },
                slide_right = function() {
                    var position = '+=100',
                        current_position = $('#column_headers').position().left,
                        stop_position = -((grid.get_num_columns_shown() - grid.get_max_visible_columns()) * 100);

                    if( stop_position <= current_position && current_position < 0 ){
                        right_arrow.find('span').addClass('disabled');
                        $('#grid_content').animate({ 'left' : position }, 'slow');
                        $('#column_headers').animate({ 'left' : position }, 'slow',
                            function() {
                                right_arrow.find('span').removeClass('disabled');
                                set_arrow_states();
                                right_arrow_trigger.trigger('hover');
                            }
                        );
                    }
                };
            
            left_arrow_trigger.hover(
                function(){ 
                    if( !left_arrow.find('span').hasClass('disabled') ){
                        slide_left();
                    }
                },
                function(){}
            );
            right_arrow_trigger.hover(
                function(){
                    if( !right_arrow.find('span').hasClass('disabled') ){
                        slide_right();
                    }
                },
                function(){}
            );

            return {
                show : show,
                hide : hide
            }
        }());

    return {
        horizontal_scroll : horizontal_scroll
    }
};

KT.comparison_grid.events = function(grid) {
    var init = function() {
            $(document).bind('draw.comparison_grid', function(event, data){
                grid.add_rows(data, false);
            });
            cell_hover();
        },
        cell_hover = function() {
            $('.grid_cell').live('hover', function(event){
                if( $(this).data('hover') ){
                    if( event.type === 'mouseenter' ){
                        $(this).find('.grid_cell_hover').show();
                        console.log('hover cell');  
                    } 

                    if( event.type === 'mouseleave' ){
                        $(this).find('.grid_cell_hover').hide();
                        console.log('hover cell');        
                    }
                }
            });
        };

    return {
        init : init
    };
};

KT.comparison_grid.templates = (function() {
    var cell = function(data) {
            var display,                
                hover = data['hover'] ? data['hover'] : "",
                html = "";

            if( data['in_column'] ){
                if( data['display'] ){
                    display = data['display'];
                } else {
                    display = '<span class="dot-icon-black"></span>';
                }
            } else {
                 display = "<span>--</span>";
            }

            if( hover !== "" ){
                html += '<div class="grid_cell cell_' + data['id'] + '" data-hover=true>';
            } else {
                html += '<div class="grid_cell cell_' + data['id'] + '">';
            }

            html += display; 
            html += '<span class="hidden grid_cell_hover">' + hover + '</span>';
            html += '</div>';

            return html;
        },
        row = function(id, num_columns, cell_data, row_level) {
            var i,
                html ='<div id="grid_row_' + id  + '" class="grid_row grid_row_level_' + row_level + '">';

            for(i = 0; i < num_columns; i += 1){
                html += cell(cell_data[i]);
            }
            html += '</div>';            

            return html;
        },
        row_header = function(id, name, row_level) {
            var html = '<li id="row_header_' + id + '" class="row_header grid_row_level_' + row_level + '">';
            html += name;
            html += '</li>';
            return html;
        },
        column = function() {
        },
        column_header = function(id, to_display) {
            var html = '<li data-id="' + id  + '" id="column_' + id + '" class="one-line-ellipsis column_header hidden">';
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
}());
