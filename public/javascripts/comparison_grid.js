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
var KT = (KT === undefined) ? {} : KT;


KT.comparison_grid = function(){
    var templates = KT.comparison_grid.templates,
        utils = KT.utils,
        controls, events,
        models = KT.comparison_grid.models(),
        num_columns_shown = 0,
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
            var cells = [], insert,
                row_level,
                cell_columns = utils.keys(cell_data);
            
            row_level = models.rows.get_nested_level(id);

            utils.each(models.columns, function(value, key){
                in_column = utils.include(cell_columns, key) ? true : false;
                
                if( in_column ){
                    cells.push({ 'in_column' : in_column, 'display' : cell_data[key]['display'], 'id' : key, 'hover' : cell_data[key]['hover'] });
                } else {
                    cells.push({ 'in_column' : in_column, 'id' : key });
                }
            });

            add_row_header(id, name, parent_id, row_level);

            if( parent_id ){
                grid_content_el.find('#grid_row_' + parent_id).after(templates.row(id, utils.size(models.columns), cells, row_level));
            } else {
                grid_content_el.append(templates.row(id, utils.size(models.columns), cells, row_level));
            }

            if( models.rows.has_children(id) ){
                add_row_collapse(id);
            }
        },
        add_row_header = function(id, name, parent_id, row_level) {
            if( parent_id ){
                grid_row_headers_el.find('#row_header_' + parent_id).after(templates.row_header(id, name, row_level));
            } else {
                grid_row_headers_el.append(templates.row_header(id, name, row_level));
            }
        },
        add_row_collapse = function(id){
            grid_row_headers_el.find('#row_header_' + id).prepend(templates.collapse_arrow);
        },
        collapse_rows = function(id, collapse){
            var parent_row_header = $('#row_header_' + KT.common.escapeId(id)),

                show = function(id, should_show){
                    var child_rows = models.rows.get_children(id);                    

                    utils.each(child_rows, function(child){
                        child = KT.common.escapeId(child);
                        if( should_show ){
                            $('#grid_row_' + child).hide();
                            $('#row_header_' + child).hide();
                        } else {
                            $('#grid_row_' + child).show();
                            $('#row_header_' + child).show();
                        }
                    });

                    if( models.rows.get_children(child_rows[0]) !== undefined ){
                        show(child_rows[0], should_show);
                    }
                };
        
            show(id, collapse);

            if( collapse ){
                parent_row_header.find('.down_arrow-icon-black').hide()
                parent_row_header.find('.right_arrow-icon-black').show();
            } else {
                parent_row_header.find('.down_arrow-icon-black').show()
                parent_row_header.find('.right_arrow-icon-black').hide();
            }
        },
        add_rows = function(append) {
            append = (append === undefined) ? false : append;

            if( !append ){
                grid_content_el.empty();
                grid_row_headers_el.empty();
            }

            utils.each(models.rows.get(), function(row, key) {
                add_row(row['id'], row['name'], row['cells'], row['parent_id']);
            });

            utils.each(models.columns, function(column, key){
                if( column['shown'] ){
                    $('.cell_' + key).show();
                } else {
                    $('.cell_' + key).hide();
                }
            });
            
            if( utils.size(models.columns) > max_visible_columns ){
                $('.grid_row').css('width', utils.size(models.columns) * 100);
            } else {
                $('.grid_row').css('width', 500);
            }
            
            set_loading(false);
        },
        set_rows = function(data, append) {
            models.rows.clear();

            utils.each(data, function(item) {
                insert = models.rows.insert(item['id'], item['name'], item['cols'], item['parent_id']);
            });

            add_rows(append);
        },
        add_columns = function() {
            $('#column_headers').empty();

            utils.each(models.columns, function(column, key) {
                add_column_header(column['id'], column['to_display']);
            });
        },
        add_column_header = function(id, to_display) {
            var column_headers = $('#column_headers');

            column_headers.append(templates.column_header(id, to_display));
        },
        set_columns = function(data){
            models.columns = {};

            utils.each(data, function(col) {
                models.columns[col['id']] = { 'id' : col['id'], 'to_display' : col['name'] };
            });

            add_columns();
        },
        show_columns = function(data){
            num_columns_shown = 0;

            utils.each(models.columns, function(value, key){
                if( data[key] ){
                    $('#column_headers').width($('#column_headers').width() + 100);
                    $('#column_' + key).show();
                    models.columns[key]['shown'] = true;
                    num_columns_shown += 1;
                    $('.cell_' + key).show();
                } else {
                    models.columns[key]['shown'] = false;
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
        },
        set_loading = function(show){
            if( show ){
                $('#grid_loading_screen').show();
            } else {
                $('#grid_loading_screen').hide();
            }
        },
        set_mode = function(mode){
            var columns_to_show = {},
                mode = (mode === undefined) ? models.mode : mode;

            if( mode === 'results' ){
                controls.column_selector.show();
                utils.each(
                    utils.filter(models.columns, 
                        function(col){
                            return col['shown'] === true;
                        }
                    ),
                    function(element, index) {
                        columns_to_show[element['id']] = {};
                    }
                );
                show_columns(columns_to_show);
            } else if( mode === 'details' ){
                controls.column_selector.hide();
                show_columns(models.columns);
                $('#grid_header').find('header h2').hide();
            }
        };

    return {
        init                    : init,
        export_data             : models.export_data,
        import_data             : models.import_data,
        add_rows                : add_rows,
        set_rows                : set_rows,
        set_columns             : set_columns,
        add_columns             : add_columns,
        show_columns            : show_columns,
        collapse_rows           : collapse_rows,
        set_loading             : set_loading,
        set_mode                : set_mode,
        get_num_columns_shown   : function(){ return num_columns_shown; },
        get_max_visible_columns : function(){ return max_visible_columns; }
    };
};

KT.comparison_grid.models = function() {
    var self = this;

    self.rows = KT.comparison_grid.models.rows();
    self.columns = KT.comparison_grid.models.columns;
    self.mode = "results";

    self.export_data = function(type) {
        if( type === "columns" ){
            return { columns : $.extend(true, {}, self.columns) };
        } else if( type === "rows" ){
            return { rows : $.extend(true, {}, self.rows.get()) };
        } else if( type === "mode" ){
            return { mode : self.mode };
        } else {
            return { columns : $.extend(true, {}, self.columns), 
                    rows : $.extend(true, {}, self.rows.get()), 
                    mode : self.mode };
        }
    };
    self.import_data = function(data) {
        if( data['columns'] !== undefined ){
            self.columns = data['columns'];
        }
        if( data['rows'] !== undefined ){
            self.rows.set(data['rows']);
        }
        if( data['mode'] !== undefined ){
            self.mode = data['mode'];
        }
        
        $(document).trigger('draw.comparison_grid');
    };

    return self;

};

KT.comparison_grid.models.columns = {};

KT.comparison_grid.models.rows = function(){
    var rows = {},
        
        clear = function() {
            rows = {};
        },
        set = function(data) {
            rows = data;
        },
        get = function(id) {
            if( id === undefined ){
                return rows;
            } else {
                return rows[id];
            }
        },
        get_parent = function(id){
            return rows[rows[id]['parent_id']];
        },
        get_children = function(id){
            return rows[id]['child_ids'];
        },
        has_children = function(id){
            return (rows[id]['child_ids'] === undefined) ? false : true;
        },
        get_nested_level = function(id) {
            var level = 1,
                parent = get_parent(id);

            if( parent !== undefined ){
                level += get_nested_level(parent['id']);
            }

            return level;
        },
        insert = function(id, name, cells, parent_id){
            var parent;

            if( parent_id ){
                rows[id] = { 'id' : id, 'name' : name, 'cells' : cells, 'parent_id' : parent_id };

                parent = get_parent(id);
                if( parent['child_ids'] === undefined ){
                    parent['child_ids'] = [id];
                    return { 'first_child' : true };
                } else {
                    parent['child_ids'].push(id);
                    return { 'first_child' : false };
                }
            } else {
                rows[id] = { 'id' : id, 'name' : name, 'cells' : cells};
            }

            return {};
        };

    return {
        get             : get,
        set             : set,
        clear           : clear,
        insert          : insert,
        get_parent      : get_parent,
        get_children    : get_children,
        has_children    : has_children,
        get_nested_level: get_nested_level
    };
        
};

KT.comparison_grid.controls = function(grid) {
    var column_selector = (function() {
        var hide = function() {
                $('#column_selector').hide();
                $('.slide_arrow[data-arrow_direction="right"]').css({ right : '-1px' });
            },
            show = function() {
                $('#column_selector').show();
                $('.slide_arrow[data-arrow_direction="right"]').css({ right : '21px' });
            };

            return {
                show : show,
                hide : hide
            };

        }()),

        horizontal_scroll = (function() {
            var right_arrow = $('.slide_arrow[data-arrow_direction="right"]'),
                right_arrow_trigger = right_arrow.find('.slide_trigger'),
                left_arrow  = $('.slide_arrow[data-arrow_direction="left"]'),
                left_arrow_trigger = left_arrow.find('.slide_trigger'),
                arrow  = $('.slide_arrow'),
                arrow_trigger = arrow.find('.slide_trigger'),

                show = function() {
                    right_arrow.show();
                    left_arrow.show();
                },
                hide = function() {
                    right_arrow.hide();
                    left_arrow.hide();
                },
                current_position = function(){
                    return $('#column_headers').position().left;
                },
                stop_position = function(){
                    return -((grid.get_num_columns_shown() - grid.get_max_visible_columns()) * 100);
                },
                set_arrow_states = function() {
                    if( current_position() === 0 ){
                        right_arrow.find('span').addClass('disabled');
                        left_arrow.find('span').removeClass('disabled');
                    } else if( stop_position() === current_position() ) {
                        left_arrow.find('span').addClass('disabled');
                        right_arrow.find('span').removeClass('disabled');
                    } else {
                        right_arrow.find('span').removeClass('disabled');
                        left_arrow.find('span').removeClass('disabled');
                    }
                },
                slide = function(direction) {
                    var position = (direction === 'left') ? '-=100' : '+=100';
                    
                    $('#grid_content').animate({ 'left' : position }, 'slow');
                    $('#column_headers').animate({ 'left' : position }, 'slow',
                        function() {
                            set_arrow_states();
                        }
                    );
                };
            
            arrow_trigger.click(
                function(){ 
                    var slide_arrow = $(this).parent(),
                        direction = slide_arrow.data('arrow_direction');
    
                    if( !slide_arrow.find('span').hasClass('disabled') ){
                        slide_arrow.find('span').addClass('disabled');

                        if( direction === "left" ){
                            if( stop_position() < current_position() && current_position() <= 0 ){
                                slide(direction);
                            }
                        } else if( direction === "right" ){
                            if( stop_position() <= current_position() && current_position() < 0 ){
                                slide(direction);
                            }
                        }
                    }
                }
            ).hover(
                function(){
                    if( !$(this).find('span').hasClass('disabled') ){
                        $(this).parent().addClass('slide_arrow_hover');
                    }
                },
                function(){ 
                    $(this).parent().removeClass('slide_arrow_hover');
                }
            );

            return {
                show : show,
                hide : hide
            }
        }());

    return {
        horizontal_scroll   : horizontal_scroll,
        column_selector     : column_selector
    }
};

KT.comparison_grid.events = function(grid) {
    var init = function() {
            $(document).bind('draw.comparison_grid', function(event, data){
                grid.set_loading(true);
                grid.add_columns();
                grid.add_rows();
                grid.set_mode();
                grid.set_loading(false);
            });

            $(document).bind('loading.comparison_grid', function(event, data){
                grid.set_loading(true);
            });

            cell_hover();
            collapseable_rows();
            details_view();
        },
        cell_hover = function() {
            $('.grid_cell').live('hover', function(event){
                if( $(this).data('hover') ){
                    if( event.type === 'mouseenter' ){
                        $(this).find('.grid_cell_hover').show();
                    } 

                    if( event.type === 'mouseleave' ){
                        $(this).find('.grid_cell_hover').hide();
                    }
                }
            });
        },
        collapseable_rows = function() {
            $('.row_header').live('click', function(){
                if( $(this).data('collapsed') ){
                    grid.collapse_rows($(this).data('id'), false);
                    $(this).data('collapsed', false);
                } else {
                    grid.collapse_rows($(this).data('id'), true);
                    $(this).data('collapsed', true);
                }
            });
        },
        details_view = function() {
            $('#return_to_results_btn').live('click', function() {
                grid.set_loading(true);
                $(document).trigger('return_to_results.comparison_grid');
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
                if( data['display'] !== undefined ){
                    display = data['display'];
                } else {
                    display = '<i class="dot-icon-black" />';
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
            var html = '<li data-id="' + id + '" id="row_header_' + id + '" class="one-line-ellipsis row_header grid_row_level_' + row_level + '">';
            html += '<span>' + name + '</span>';
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
        },
        collapse_arrow = function(){
            return '<i class="down_arrow-icon-black"/><i class="right_arrow-icon-black" style="display:none;"/>';
        };

    return {
        cell            : cell,
        row             : row,
        column_header   : column_header,
        row_header      : row_header,
        collapse_arrow  : collapse_arrow
    }
}());
