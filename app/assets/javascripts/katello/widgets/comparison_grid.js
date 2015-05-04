/**
 Copyright 2014 Red Hat, Inc.

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
        events,
        models = KT.comparison_grid.models(),
        num_columns_shown = 0,
        grid_row_headers_el,
        grid_content_el,
        default_row_level = 0,
        max_visible_columns = 7;

    var init = function(){
            events = KT.comparison_grid.events(this).init();
            grid_row_headers_el = $('#grid_row_headers');
            grid_content_el = $('#grid_content');
            controls = KT.comparison_grid.controls(this);
            default_row_level = 0;
        },
        add_row = function(id, name, type, cell_data, parent_id, comparable){
            var cells = [],
                cell_columns = utils.keys(cell_data),
                has_children = models.rows.has_children(id),
                row_element,
                parent,
                row_level = models.rows.get_nested_level(id) - 1 + default_row_level;

            utils.each(models.columns, function(col){
                in_column = utils.include(cell_columns, '' + col['id']) ? true : false;

                if( in_column ){
                    cells.push({'in_column' : in_column, 'display' : cell_data[col['id']]['display'], 'span' : col['span'],
                                'id' : col['id'], 'hover' : cell_data[col['id']]['hover'],
                                'hover_details' : cell_data[col['id']]['hover_details'],
                                'comparable' : comparable, 'row_id' : id });
                } else {
                    cells.push({ 'in_column' : in_column, 'id' : col['id'], 'span' : col['span'], 'row_id' : id });
                }
            });

            add_row_header(id, name, type, row_level, has_children, parent_id);

            row_element = templates.row(id, models.columns.length, cells, row_level, has_children, parent_id, name, type);

            if( parent_id ){
                parent = $('#child_list_' + parent_id);
            } else {
                parent = grid_content_el;
            }

            if( parent.children('.load_row').length > 0 ){
                parent.children('.load_row').before(row_element);
            } else {
                parent.append(row_element);
            }
        },
        add_metadata_row = function(id, parent_id, page_size, current, total){
            var child_list;

            if( $('.load_row[data-id="' + id + '"]').length === 0 ){
                add_metadata_row_header(id, parent_id);

                if( parent_id ){
                    child_list = $('#child_list_' + parent_id);
                    child_list.append(templates.load_more_row(id, page_size, current, total));
                } else {
                    grid_content_el.append(templates.load_more_row(id, page_size, current, total));
                }
            }
        },
        add_metadata_row_header = function(id, parent_id) {
            var child_list;

            if( parent_id ){
                child_list = $('#child_header_list_' + parent_id);

                child_list.append(templates.load_more_row_header(id, parent_id));
            } else {
                grid_row_headers_el.append(templates.load_more_row_header(id, parent_id));
            }
        },
        update_metadata_row = function(id, current, total){
            var metadata_row = $('.load_row[data-id="' + id + '"]');

            if( current === total ){
                metadata_row.remove();
                $('#row_header_' + id).remove();
            } else {
                metadata_row.find('span').html(katelloI18n.counts.replace('%C', current).replace('%T', total));
            }
        },
        add_row_header = function(id, name, type, row_level, has_children, parent_id) {
            var parent;

            if( parent_id ){
                parent = $('#child_header_list_' + parent_id);
            } else {
                parent = grid_row_headers_el;
            }

            if( parent.children('.load_row_header').length > 0 ) {
                parent.children('.load_row_header').before(templates.row_header(id, name, type, row_level, has_children, parent_id));
            } else {
                parent.append(templates.row_header(id, name, type, row_level, has_children, parent_id));
            }
        },
        add_rows = function(append) {
            append = (append === undefined) ? false : append;

            if( !append ){
                grid_content_el.empty();
                grid_row_headers_el.empty();
            }

            if( append ){
                utils.each(append, function(row, key) {
                    if( row['metadata'] ){
                        update_metadata_row(row['id'], row['current'], row['total']);
                    } else {
                        add_row(row['id'], row['name'], row['data_type'], row['cells'], row['parent_id'], row['comparable']);
                    }
                });
            } else {
                utils.each(models.rows.get(), function(row, key) {
                    if( row['metadata'] ){
                        add_metadata_row(row['id'], row['parent_id'], row['page_size'], row['current'], row['total']);
                    } else {
                        add_row(row['id'], row['name'], row['data_type'], row['cells'], row['parent_id'], row['comparable']);
                    }
                });
            }

            utils.each(models.columns, function(column){
                if( column['shown'] ){
                    $('.cell_' + column['id']).show();
                } else {
                    $('.cell_' + column['id']).hide();
                }
            });

            if( models.columns.length > max_visible_columns ){
                $('.grid_row').css('width',
                    utils.reduce(models.columns, function(memo, col){ return ((parseInt(col['span'], 10) * 100) + memo); }, 0));
            } else {
                $('.grid_row').css('width', 100 * max_visible_columns);
            }

            $('.load_row').find('.spinner').css('visibility', 'hidden');
            $('.load_row').find('a').removeClass('disabled');

            $('.three-line-ellipsis').trunk8({
                lines   : 3
            });

            set_loading(false);
        },
        set_rows = function(data, initial) {
            var append_rows, insert;

            if( initial ){
                models.rows.clear();
            } else {
                append_rows = [];
            }

            utils.each(data, function(item) {
                if( item['metadata'] ){
                    insert = models.rows.insert_metadata(item['id'], item['parent_id'], item['page_size'], item['current_count'], item['total'], item['data']);

                    if( !initial ){
                        append_rows.push(insert);
                    }
                } else {
                    insert = models.rows.insert(item['id'], item['name'], item['cols'], item['parent_id'], item['comparable'], item['data_type'], item['value']);

                    if( !initial ){
                        append_rows.push(insert);
                    }
                }
            });

            if( initial ){
                add_rows();
            } else {
                add_rows(append_rows);
            }
        },
        add_columns = function() {
            $('#column_headers').empty();

            utils.each(models.columns, function(column) {
                add_column_header(column['id'], column['to_display'], column['span']);
            });
        },
        add_column_header = function(id, to_display, span) {
            var column_headers = $('#column_headers');

            column_headers.append(templates.column_header(id, to_display, span));
        },
        set_columns = function(data){
            models.columns = [];

            utils.each(data, function(col) {
                var to_display, custom;

                if( col['content'] ){
                    to_display = col['content']['custom'] ? col['content'] : col['content']['name'],
                    custom = col['content']['custom'] ? true : false;
                } else {
                    to_display = col['name'];
                    custom = false;
                }

                models.columns.push({ 'id' : col['id'], 'to_display' : { 'content' : to_display, 'custom' : custom },
                                            'span' : col['span'] ? col['span'] : 1 });
            });

            add_columns();
        },
        show_columns = function(data){
            var last_visible,
                previous_num_shown = num_columns_shown;

            num_columns_shown = 0;

            utils.each(models.columns, function(column){
                if( data[column['id']] ){
                    column['shown'] = true;
                    num_columns_shown += parseInt(column['span'], 10);
                    $('.cell_' + column['id']).show();
                    $('#column_' + column['id']).show();
                } else {
                    column['shown'] = false;
                    $('#column_' + column['id']).hide();
                    $('.cell_' + column['id']).hide();
                }
            });

            $('#column_headers').width(num_columns_shown * 100 + 1);

            if( num_columns_shown > max_visible_columns ){

                if( previous_num_shown > num_columns_shown ){
                    if( $('#column_headers').find(':not(:hidden)').last().position().left + 100 === -($('#column_headers').position().left) + 400 ){
                        controls.horizontal_scroll.slide('right');
                    }
                }
                controls.horizontal_scroll.show();
                $('#column_headers_window').width(100 * max_visible_columns + 1);
            } else {
                controls.horizontal_scroll.reset();
                controls.horizontal_scroll.hide();
                $('#column_headers_window').width(num_columns_shown * 100);
            }
        },
        set_loading = function(show){
            if( show ){
                $('#grid_loading_screen').height($('#grid_content_window').height()).show();
            } else {
                $('#grid_loading_screen').hide();
            }
        },
        set_mode = function(mode, options){
            var columns_to_show = {};
            options = options || {};
            models.mode = (mode === undefined) ? models.mode : mode;

            if( models.mode === 'results' ){
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
                $('#grid_header').find('header h2[data-title="results"]').show();
                $('#grid_header').find('header h2[data-title="details"]').hide();
                $('#return_to_results_btn').hide();
            } else if( models.mode === 'details' ){
                controls.column_selector.hide();
                show_columns(models.columns);
                $('#grid_header').find('header h2[data-title="results"]').hide();
                $('#grid_header').find('header h2[data-title="details"]').show();
                $('#grid_header').find('header .button').show();
            }
            if(options['show_compare_btn']){
                controls.comparison.show();
            }
            else{
                controls.comparison.hide();
            }
            if(options['right_selector']){
                controls.right_select.show();
            }
            else {
                controls.right_select.hide();
            }
            if(options['left_selector']){
                controls.left_select.show();
            }
            else {
                controls.left_select.hide();
            }

        },
        set_default_row_level = function(level) {
            default_row_level = level;
        },
        set_left_select = function(options, selected){
            controls.left_select.set(options, selected);
        },
        set_right_select = function(options, selected){
            controls.right_select.set(options, selected);
        },
        set_title = function(title){
            $('#grid_header').find('header h2[data-title="details"]').html(title);
        },
        set_templates = function(templates_object) {
            templates = templates_object;
        };

    return {
        init                    : init,
        controls                : function(){return controls;},
        models                  : models,
        export_data             : models.export_data,
        import_data             : models.import_data,
        add_rows                : add_rows,
        set_rows                : set_rows,
        set_columns             : set_columns,
        add_columns             : add_columns,
        show_columns            : show_columns,
        set_loading             : set_loading,
        set_mode                : set_mode,
        set_default_row_level   : set_default_row_level,
        set_left_select         : set_left_select,
        set_right_select        : set_right_select,
        set_title               : set_title,
        get_num_columns_shown   : function(){ return num_columns_shown; },
        get_max_visible_columns : function(){ return max_visible_columns; },
        set_templates           : set_templates
    };
};

KT.comparison_grid.models = function() {
    var self = this;

    self.rows = KT.comparison_grid.models.rows();
    self.columns = KT.comparison_grid.models.columns;
    self.mode = "results";

    self.export_data = function(type) {
        if( type === "columns" ){
            return { columns :$.extend(true, [], self.columns) };
        } else if( type === "rows" ){
            return { rows : $.extend(true, {}, self.rows.get()) };
        } else if( type === "mode" ){
            return { mode : self.mode };
        } else {
            return { columns : $.extend(true, [], self.columns),
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

KT.comparison_grid.models.columns = [];

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
        insert = function(id, name, cells, parent_id, comparable, data_type, value){
            if( parent_id ){
                rows[id] = { 'id' : id, 'name' : name, 'cells' : cells,
                            'parent_id' : parent_id, 'comparable' : comparable,
                            'data_type' : data_type, 'value' : value };

                var parent = get_parent(id);

                if (parent) {
                    if( parent['child_ids'] === undefined ){
                        parent['child_ids'] = [id];
                    } else {
                        parent['child_ids'].push(id);
                    }
                }
            } else {
                rows[id] = { 'id' : id, 'name' : name, 'cells' : cells, 'comparable' : comparable, 'data_type' : data_type, 'value' : value };
            }

            return rows[id];
        },
        insert_metadata = function(id, parent_id, page_size, current, total, data){
            rows[id] = { 'id' : id, 'parent_id' : parent_id, 'data' : data, 'metadata' : true,
                        'page_size' : page_size, 'current' : current, 'total' : total };

            return rows[id];
        };

    return {
        get             : get,
        set             : set,
        clear           : clear,
        insert          : insert,
        insert_metadata : insert_metadata,
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
                $('.slide_arrow[data-arrow_direction="right"]').css({ right : '25px' });
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
                    $('#more_columns_fade').show();
                },
                hide = function() {
                    right_arrow.hide();
                    left_arrow.hide();
                    $('#more_columns_fade').hide();
                },
                current_position = function(){
                    return $('#column_headers').position().left;
                },
                stop_position = function(){
                    return -((grid.get_num_columns_shown() - grid.get_max_visible_columns()) * 100);
                },
                reset = function(){
                    var distance = $('#grid_content').css('left');

                    $('#grid_content').animate({ 'left' : 0 }, 'fast');
                    $('#column_headers').animate({ 'left' : 0 }, 'fast',
                        function() {
                            set_arrow_states();
                        }
                    );

                },
                set_arrow_states = function() {
                    if( current_position() === 0 ){
                        left_arrow.find('span').addClass('disabled');
                        right_arrow.find('span').removeClass('disabled');

                        if( right_arrow.is(":visible") ){
                            $('#more_columns_fade').show();
                        }
                    } else if( stop_position() === current_position() ) {
                        right_arrow.find('span').addClass('disabled');
                        left_arrow.find('span').removeClass('disabled');
                        $('#more_columns_fade').hide();
                    } else {
                        right_arrow.find('span').removeClass('disabled');
                        left_arrow.find('span').removeClass('disabled');
                        if( right_arrow.is(":visible") ){
                            $('#more_columns_fade').show();
                        }
                    }
                },
                slide = function(direction) {
                    var position = (direction === 'left') ? '+=100' : '-=100';

                    $('#grid_content').animate({ 'left' : position }, 'fast');
                    $('#column_headers').animate({ 'left' : position }, 'fast',
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

                        if( direction === "right" ){
                            if( stop_position() < current_position() && current_position() <= 0 ){
                                slide(direction);
                            }
                        } else if( direction === "left" ){
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
                show    : show,
                hide    : hide,
                slide   : slide,
                reset   : reset
            };
        }()),

        generic_select = function(id){
            var container = $(id),
                selector = container.find('select'),

                set = function(options, selected_id){
                    var html = "";

                    selector.empty();
                    KT.utils.each(options, function(option){
                        html += '<option value="' + option['id'] + '"' ;
                        if (option['id'] === selected_id){
                            html += "selected=selected";
                        }
                        html += '>' + option['name'] + '</option>';
                    });

                    selector.append(html);
                    selector.chosen({disable_search_threshold: 3});
                    selector.trigger("liszt:updated");
                },
                show = function(){
                    container.show();
                },
                hide = function(){
                    container.hide();
                };

            return {
                set     : set,
                show    : show,
                hide    : hide
            };
        },
        comparison = (function(){
            var show = function(){
                var elements = $('.grid_cell').find('input[type="checkbox"]:checked');

                $('#compare_btn').show();

                if( elements.length < 2 ){
                    $('#compare_btn').addClass('disabled');
                }
            },
            hide = function(){
                $('#compare_btn').hide();
            };
            return {
                show:show,
                hide:hide
            };
        }()),
        row_collapse = (function(){
            var init = function(grid) {
                    $('.row_header[data-collapsed]').live('click', function(){
                        if( $(this).data('collapsed') ){
                            expand($(this).data('id'), grid.models.rows);
                            $(this).data('collapsed', false);
                        } else {
                            collapse($(this).data('id'), grid.models.rows);
                            $(this).data('collapsed', true);
                        }
                    });
                },
                show = function(id, should_show, rows){
                    if( should_show ){
                        $('#child_list_' + id).show();
                        $('#child_header_list_' + id).show();
                    } else {
                        $('#child_list_' + id).hide();
                        $('#child_header_list_' + id).hide();
                    }
                },
                collapse = function(id, rows){
                    var parent_row_header = $('#row_header_' + KT.common.escapeId(id));

                    show(id, false, rows);

                    parent_row_header.find('.fa.fa-chevron-down').hide();
                    parent_row_header.find('.fa.fa-chevron-right').show();
                },
                expand = function(id, rows){
                    var parent_row_header = $('#row_header_' + KT.common.escapeId(id));

                    show(id, true, rows);

                    parent_row_header.find('.fa.fa-chevron-down').show();
                    parent_row_header.find('.fa.fa-chevron-right').hide();
                };

            return {
                init        : init,
                expand      : expand,
                collapse    : collapse
            };
        }()).init(grid);

    return {
        horizontal_scroll       : horizontal_scroll,
        column_selector         : column_selector,
        row_collapse            : row_collapse,
        left_select             : generic_select("#left_select"),
        right_select            : generic_select("#right_select"),
        comparison              : comparison
    };
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

            $(document).bind('show_more.comparison_grid', function(event, data){
                grid.set_rows(data);
            });

            cell_hover();
            details_view();
            change_selectors();
            load_row_links();
            comparable_cells();
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
            $('.hover_details').tooltip({ gravity : 'w', live : true, html : true });
        },
        details_view = function() {
            $('#return_to_results_btn').live('click', function() {
                grid.set_loading(true);
                $(document).trigger('return_to_results.comparison_grid');
            });
        },
        change_selectors = function() {
            $('#left_select').find('select').live('change', function(){
                $(document).trigger({ type : 'left_select.comparison_grid', value : $(this).val() });
            });
            $('#right_select').find('select').live('change', function(){
                $(document).trigger({ type : 'right_select.comparison_grid', value : $(this).val() });
            });
        },
        comparable_cells = function(){
            $('#compare_btn').live('click', function(){
                var elements = $('.grid_cell').find('input[type="checkbox"]:checked'),
                    selected = [],
                    type = "";

                KT.utils.each(elements, function(item){
                    selected.push({ col_id : $(item).val(), row_id : $(item).attr('name') });

                });
                type = "compare_" + $("select#content").val() + ".comparison_grid";
                $(document).trigger({ type : type, selected : selected });
            });
            $('.grid_cell').find('input[type="checkbox"]').live('click', function(){
                var elements = $('.grid_cell').find('input[type="checkbox"]:checked');

                if( elements.length < 2 ){
                    $('#compare_btn').addClass('disabled');
                } else {
                    if( $('#compare_btn').hasClass('disabled') ){
                        $('#compare_btn').removeClass('disabled');
                    }
                }
            });
        },
        load_row_links = function(){
            $('.load_row_link').live('click', function(event){
                var cell = grid.models.rows.get($(this).parent().data('id'));
                event.preventDefault();

                if( !$(this).hasClass('disabled') ){
                    $(this).addClass('disabled').parent().find('.spinner').css('visibility', 'visible');
                    $(document).trigger({type : 'load_more.comparison_grid', cell_data : cell['data'], offset : cell['current']});
                }
            });
        };

    return {
        init : init
    };
};

KT.comparison_grid.templates = (function(i18n) {
    var auto_collapse_rows = [2, 3];

    var cell = function(data, row_height) {
            var display,
                hover = data['hover'] ? data['hover'] : false,
                hover_details =  '',
                html = $('<div/>', {
                            'data-span' : data['span'],
                            'class'     : 'grid_cell cell_' + data['id']
                        });

            if ( data['hover_details'] ) {
                hover_details = $('<span/>', {
                    'class' : 'fa fa-question-circle hover_details',
                    'title' : data['hover_details'],
                    'data-html': true
                });
            }

            if( data['in_column'] ){
                if( data['display'] !== undefined ){
                    display = '<div class="grid_cell_data three-line-ellipsis">' + data['display'] + '</div>';
                } else {
                    display = $('<i/>', { 'class' : "icon-circle" });
                }
            } else {
                 display = "<i>--</i>";
            }

            html.append(display);

            if( hover ){
                html.attr('data-hover', true);

                if( row_height ){
                    html.append($('<span/>', { 'class' : "hidden grid_cell_hover " + row_height,
                                               'data-span' : data['span'],
                                               'html' : hover_details.before(hover) }));
                } else {
                    html.append($('<span/>', { 'class' : "hidden grid_cell_hover",
                                               'data-span' : data['span'],
                                               'html' : hover_details.before(hover) }));
                }
            }

            if( data['comparable'] && data['in_column'] ){
                html.append($('<input/>', {
                        'type' : 'checkbox',
                        'name' : data['row_id'],
                        'value': data['id']
                    }));
            }

            return html;
        },
        row = function(id, num_columns, cell_data, row_level, has_children, parent_id, name, type) {
            var i,
                html = $('<div/>', {
                    'id'    : 'grid_row_' + id,
                    'class' : 'grid_row grid_row_level_' + row_level
                });

            name = this.row_header_content(name, type);
            if( parent_id !== undefined ){
                html.attr('data-parent_id', parent_id);
            }

            if( name.length <= 30 ) {
                for(i = 0; i < num_columns; i += 1){
                    html.append(cell(cell_data[i]));
                }
            } else if( name.length > 30 && name.length < 51 ) {
                html.addClass('row_height_2');
                for(i = 0; i < num_columns; i += 1){
                    html.append(cell(cell_data[i], 'row_height_2'));
                }

            } else if( name.length >= 51 ){
                html.addClass('row_height_3');
                for(i = 0; i < num_columns; i += 1){
                    html.append(cell(cell_data[i], 'row_height_3'));
                }
            }

            if( has_children ){
                html.attr('data-collapsed', "false");
            }

            var temp_html = $('<div/>');

            temp_html.append(html);

            if( has_children ){
                if (KT.utils.contains(auto_collapse_rows, row_level)) {
                    temp_html.append($('<ul/>', { 'id' : 'child_list_' + id, 'class' : 'hidden' }));
                } else {
                    temp_html.append($('<ul/>', { 'id' : 'child_list_' + id }));
                }
            }

            return temp_html.html();
        },
        row_header_content = function(name, type) {
            // override me
            return name;
        },
        row_header = function(id, name, type, row_level, has_children, parent_id) {
            var html = $('<li/>', {
                            'data-id'   : id,
                            'id'        : 'row_header_' + id,
                            'class'     : 'row_header grid_row_level_' + row_level
                        });

            if( parent_id !== undefined ){
                html.attr('data-parent_id', parent_id);
            }
            name = this.row_header_content(name, type);

            if( row_level === 2 ){
                if( name.length > 30 && name.length < 51 ){
                    html.addClass('row_height_2');
                    html.append($('<span/>', { 'class': 'one-line-ellipsis'}).html(name));
                } else if( name.length >= 51 && name.length <= 94 ){
                    html.addClass('row_height_3');
                    html.append($('<span/>', { 'class': 'one-line-ellipsis'}).html(name));
                } else if( name.length > 94 ) {
                    html.addClass('row_height_3');
                    html.append($('<span/>', { 'class' : 'three-line-ellipsis tipsify', 'title' : name }).html(name));
                } else {
                    html.append($('<span/>', { 'class': 'one-line-ellipsis'}).html(name));
                }
            } else if( row_level >= 3 ){
                if( name.length > 30 ){
                    html.addClass('row_height_2');
                }
                html.append($('<span/>', { 'class': 'one-line-ellipsis'}).html(name));
            } else {
                if( (has_children && name.length > 26) || (parent_id && name.length > 28) || name.length > 28 ){
                    html.append($('<span/>', { 'class' : 'one-line-ellipsis tipsify', 'title' : name }).html(name));
                } else {
                    html.append($('<span/>').html(name));
                }
            }

            var temp_html = $('<div/>');

            if( has_children ){
                if (KT.utils.contains(auto_collapse_rows, row_level)) {
                    html.prepend(collapse_arrow({ open : false }));
                    html.attr('data-collapsed', "true");
                    temp_html.append(html);
                    temp_html.append($('<ul/>', { 'id' : 'child_header_list_' + id, 'class' : 'hidden' }));
                } else {
                    html.prepend(collapse_arrow({ open : true }));
                    html.attr('data-collapsed', "false");
                    temp_html.append(html);
                    temp_html.append($('<ul/>', { 'id' : 'child_header_list_' + id }));
                }
            } else {
                temp_html.append(html);
            }

            return temp_html.html();
        },
        column_header = function(id, to_display, span) {
            var html = $('<li/>', {
                    'id'        : 'column_' + id,
                    'data-id'   : id,
                    'data-span' : span,
                    'class'     : 'column_header hidden'
                }).html(to_display['content']);

            if( !to_display['custom'] ){
                if( to_display['content'].length > span * 12 ){
                    html.addClass('tipsify one-line-ellipsis').attr('title', to_display['content']);
                }
            }

            return html;
        },
        collapse_arrow = function(options){
            var html;

            if( options['open'] ){
                html = '<i class="fa fa-chevron-down"/><i class="fa fa-chevron-right" style="display:none;"/>';
            } else {
                html = '<i class="fa fa-chevron-down" style="display:none;" /><i class="fa fa-chevron-right" />';
            }

            return html;
        },
        load_more_row = function(id, load_size, current, total){
            var html = $('<div/>', {
                            'class'     : 'load_row grid_row',
                            'data-id'   : id
                        });

            html.append('<i class="fl spinner invisible" />');
            html.append('<a class="load_row_link fl" href="" >' + i18n.show_more.replace('%P', load_size) + '</a>');
            html.append('<i class="fa fa-chevron-down"/>');
            html.append($('<span/>').html(i18n.counts.replace('%C', current).replace('%T', total)));

            return html;
        },
        load_more_row_header = function(id, parent_id){
            var html = $('<li/>', {
                            'data-id'   : id,
                            'id'        : 'row_header_' + id,
                            'class'     : 'one-line-ellipsis row_header load_row_header grid_row_level_3'
                        });

            if( parent_id !== undefined ){
                html.attr('data-parent_id', parent_id);
            }

            return html;
        };

    return {
        cell                    : cell,
        row                     : row,
        row_header              : row_header,
        row_header_content      : row_header_content,
        column_header           : column_header,
        load_more_row_header    : load_more_row_header,
        load_more_row           : load_more_row,
        collapse_arrow          : collapse_arrow
    };
}(katelloI18n));
