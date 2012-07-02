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
        add_row = function(id, name, cell_data, parent_id, comparable){
            var cells = [], insert,
                row_level,
                cell_columns = utils.keys(cell_data),
                child_list,
                has_children = models.rows.has_children(id);
 
            if( models.mode === "results" ){           
                row_level = models.rows.get_nested_level(id);
            } else {
                row_level = 3;
            }

            utils.each(models.columns, function(value, key){
                in_column = utils.include(cell_columns, key) ? true : false;
                
                if( in_column ){
                    cells.push({'in_column' : in_column, 'display' : cell_data[key]['display'], 'span' : value['span'],
                                'id' : key, 'hover' : cell_data[key]['hover'], 'comparable' : comparable });
                } else {
                    cells.push({ 'in_column' : in_column, 'id' : key, 'span' : value['span'] });
                }
            });

            add_row_header(id, name, row_level, has_children, parent_id);

            if( parent_id ){
                child_list = $('#child_list_' + parent_id);
                
                child_list.append(templates.row(id, utils.size(models.columns), cells, row_level, has_children, parent_id));
            } else {
                grid_content_el.append(templates.row(id, utils.size(models.columns), cells, row_level, has_children));
            }

            if( has_children ){
                add_row_collapse(id);
            }
        },
        add_metadata_row = function(id, parent_id, page_size){
            var child_list;

            if( $('.load_row[data-id="' + id + '"]').length === 0 ){
                add_row_header(id, '', 3, false, parent_id);

                if( parent_id ){
                    child_list = $('#child_list_' + parent_id);
                    child_list.append(templates.load_more_row(id, page_size));
                } else {
                    grid_content_el.append(templates.load_more_row(id, page_size));
                }
            }
        },
        add_row_header = function(id, name, row_level, has_children, parent_id) {
            var child_list;

            if( parent_id ){
                child_list = $('#child_header_list_' + parent_id);
                
                child_list.append(templates.row_header(id, name, row_level, has_children, parent_id));
            } else {
                grid_row_headers_el.append(templates.row_header(id, name, row_level, has_children, parent_id));
            }
        },
        add_row_collapse = function(id){
            grid_row_headers_el.find('#row_header_' + id).prepend(templates.collapse_arrow);
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
                        add_metadata_row(row['id'], row['parent_id'], row['page_size']);
                    } else {
                        add_row(row['id'], row['name'], row['cells'], row['parent_id'], row['comparable']);
                    }
                });
            } else {
                utils.each(models.rows.get(), function(row, key) {
                    if( row['metadata'] ){
                        add_metadata_row(row['id'], row['parent_id'], row['page_size']);
                    } else {
                        add_row(row['id'], row['name'], row['cells'], row['parent_id'], row['comparable']);
                    }
                });
            }

            utils.each(models.columns, function(column, key){
                if( column['shown'] ){
                    $('.cell_' + key).show();
                } else {
                    $('.cell_' + key).hide();
                }
            });
            
            if( utils.size(models.columns) > max_visible_columns ){
                $('.grid_row').css('width', 
                    utils.reduce(models.columns, function(memo, col){ return ((parseInt(col['span'], 10) * 100) + memo); }, 0));
            } else {
                $('.grid_row').css('width', 500);
            }
            
            set_loading(false);
        },
        set_rows = function(data, initial) {
            var append_rows, insert;

            if( initial ){
                models.rows.clear();
            } else {
                append_rows = []
            }

            utils.each(data, function(item) {
                if( item['metadata'] ){
                    insert = models.rows.insert_metadata(item['id'], item['parent_id'], item['page_size'], item['current'], item['total'], item['data']);
                } else {
                    insert = models.rows.insert(item['id'], item['name'], item['cols'], item['parent_id'], item['comparable']);

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

            utils.each(models.columns, function(column, key) {
                add_column_header(column['id'], column['to_display'], column['span']);
            });
        },
        add_column_header = function(id, to_display, span) {
            var column_headers = $('#column_headers');

            column_headers.append(templates.column_header(id, to_display, span));
        },
        set_columns = function(data){
            models.columns = {};

            utils.each(data, function(col) {
                models.columns[col['id']] = { 'id' : col['id'], 'to_display' : col['name'], 
                                            'span' : col['span'] ? col['span'] : 1 };
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
                    num_columns_shown += models.columns[key]['span'];
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
            var columns_to_show = {};
                
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
                controls.change_content_select.hide();
            } else if( models.mode === 'details' ){
                controls.column_selector.hide();
                show_columns(models.columns);
                $('#grid_header').find('header h2[data-title="results"]').hide();
                $('#grid_header').find('header h2[data-title="details"]').show();
                $('#grid_header').find('header .button').show();
                controls.change_content_select.show();
            }
        },
        set_content_select = function(options){
            controls.change_content_select.set(options);
        },
        set_title = function(title){
            $('#grid_header').find('header h2[data-title="details"]').html(title);
        };

    return {
        init                    : init,
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
        set_content_select      : set_content_select,
        set_title               : set_title,
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
        insert = function(id, name, cells, parent_id, comparable){
            if( parent_id ){
                rows[id] = { 'id' : id, 'name' : name, 'cells' : cells, 
                            'parent_id' : parent_id, 'comparable' : comparable };

                parent = get_parent(id);
                if( parent['child_ids'] === undefined ){
                    parent['child_ids'] = [id];
                } else {
                    parent['child_ids'].push(id);
                }
            } else {
                rows[id] = { 'id' : id, 'name' : name, 'cells' : cells, 'comparabale' : comparable };
            }
            
            return rows[id];
        },
        insert_metadata = function(id, parent_id, page_size, current, total, data){
            rows[id] = { 'id' : id, 'parent_id' : parent_id, 'data' : data, 'metadata' : true,
                        'page_size' : page_size, 'current' : current, 'total' : total };
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
        }()),

        change_content_select = (function(){
            var container = $('#change_content_select'),
                selector = container.find('select'),
                
                set = function(options){
                    var html = "";

                    selector.empty();

                    KT.utils.each(options, function(option){ 
                        html += '<option value="' + option['id'] + '">' + option['name'] + '</option>';
                    });

                    selector.append(html);
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
                    var child_rows = rows.get_children(id);                    

                    KT.utils.each(child_rows, function(child){
                        child = KT.common.escapeId(child);
                        if( should_show ){
                            $('#grid_row_' + child).show();
                            $('#row_header_' + child).show();
                        } else {
                            $('#grid_row_' + child).hide();
                            $('#row_header_' + child).hide();
                        }
                    });

                    if( rows.get_children(child_rows[0]) !== undefined ){
                        show(child_rows[0], should_show, rows);
                    }
                },
                collapse = function(id, rows){
                    var parent_row_header = $('#row_header_' + KT.common.escapeId(id));

                    show(id, false, rows);

                    parent_row_header.find('.down_arrow-icon-black').hide()
                    parent_row_header.find('.right_arrow-icon-black').show();
                },
                expand = function(id, rows){
                    var parent_row_header = $('#row_header_' + KT.common.escapeId(id));

                    show(id, true, rows);

                    parent_row_header.find('.down_arrow-icon-black').show()
                    parent_row_header.find('.right_arrow-icon-black').hide();
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
        change_content_select   : change_content_select
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

            $(document).bind('show_more.comparison_grid', function(event, data){
                grid.set_rows(data);
            });

            cell_hover();
            details_view();
            change_details_content();
            load_row_links();
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
        details_view = function() {
            $('#return_to_results_btn').live('click', function() {
                grid.set_loading(true);
                $(document).trigger('return_to_results.comparison_grid');
            });
        },
        change_details_content = function() {
            $('#change_content_select').find('select').live('change', function(){
                $(document).trigger({ type : 'change_details_content.comparison_grid', content_type : $(this).val() });
            });
        },
        comparable_cells = function(){
            $('#compare_repos_btn').live('click', function(){
                var selected = $('.grid_cell').find('input[type="checkbox"]:checked').val();

                $(document).trigger({ type : 'compare.comparison_grid', selected : selected });
            });
        },
        load_row_links = function(){
            $('.load_row_link').live('click', function(){
                var id = $(this).data('id');

                $(document).trigger({ type : 'load_more.comparison_grid', data : grid.models.rows.get(id)['data'] })
            });
        };

    return {
        init : init
    };
};

KT.comparison_grid.templates = (function(i18n) {
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
                html += '<div data-span="' + data['span'] + '" class="grid_cell cell_' + data['id'] + '" data-hover=true>';
            } else {
                html += '<div data-span="' + data['span'] + '" class="grid_cell one-line-ellipsis cell_' + data['id'] + '">';
            }

            html += display; 
            if( hover !== "" ){
                html += '<span class="hidden grid_cell_hover">' + hover + '</span>';
            }

            if( data['comparable'] && data['in_column'] ){
                html += '<input type="checkbox" name="compare" value="" />';
            }
            html += '</div>';

            return html;
        },
        row = function(id, num_columns, cell_data, row_level, has_children, parent_id) {
            var i,
                html ='<div ';
            
            if( parent_id !== undefined ){
                html += 'data-parent_id="' + parent_id + '" ';
            }

            html += 'id="grid_row_' + id  + '" class="grid_row grid_row_level_' + row_level + '"'; 

            if( has_children ){
                html += ' collapsed="false"';
            }

            html += '>';

            for(i = 0; i < num_columns; i += 1){
                html += cell(cell_data[i]);
            }
            html += '</div>';            

            if( has_children ){
                html += '<ul id="child_list_' + id + '"></ul>';
            }

            return html;
        },
        row_header = function(id, name, row_level, has_children, parent_id) {
            var html = '<li data-id="' + id + '" id="row_header_' + id + '" class="one-line-ellipsis row_header grid_row_level_' + row_level + '" ';

            if( parent_id !== undefined ){
                html += 'data-parent_id="' + parent_id + '"';
            }
            
            if( has_children ){
                html += ' data-collapsed="false"';
            }

            html += '>';
            html += '<span>' + name + '</span>';
            html += '</li>';

            if( has_children ){
                html += '<ul id="child_header_list_' + id + '"></ul>';
            }
    
            return html;
        },
        column = function() {
        },
        column_header = function(id, to_display, span) {
            var html = '';
 
            html += '<li data-id="' + id  + '" id="column_' + id + '" data-span="' + span + '" class="one-line-ellipsis column_header hidden">';
            html += to_display;
            html += '</li>';

            return html;
        },
        collapse_arrow = function(){
            return '<i class="down_arrow-icon-black"/><i class="right_arrow-icon-black" style="display:none;"/>';
        },
        load_more_row = function(id, load_size){
            var html = '<div class="load_row grid_row" data-id="' + id + '">';
                
            html += '<a class="load_row_link" href="#" >' + i18n.show_more.replace('%P', load_size) + '</a>';
            html += '<i class="down_arrow-icon-black"/>';
            html += '</div>';

            return html;
        };

    return {
        cell            : cell,
        row             : row,
        column_header   : column_header,
        row_header      : row_header,
        load_more_row   : load_more_row,
        collapse_arrow  : collapse_arrow
    }
}(i18n));

var base_test_data = [{"cols":{"1":{"id":1,"display":8},"2":{"id":2,"display":8}},"id":"product_1","name":"TestProduct"},{"parent_id":"product_1","cols":{"1":{"id":1,"display":8},"2":{"id":2,"display":8}},"id":"repo_5","name":"RealZoo"},{"parent_id":"repo_5","cols":{"1":{"id":1},"2":{"id":2}},"id":"package_362a37c2-53ec-462a-b700-fedbb74a8c1c","name":"squirrel-0.3-0.8.noarch"},{"parent_id":"repo_5","cols":{"1":{"id":1},"2":{"id":2}},"id":"package_8ff8c507-de0b-4e2f-a275-1df7cb5137aa","name":"monkey-0.3-0.8.noarch"},{"parent_id":"repo_5","cols":{"1":{"id":1},"2":{"id":2}},"id":"package_60ff9196-cf4e-4bba-9b02-06004403212d","name":"elephant-0.3-0.8.noarch"},{"parent_id":"repo_5","cols":{"1":{"id":1},"2":{"id":2}},"id":"package_1aadf3eb-fbbd-41c4-8ea0-13c356efb7e5","name":"giraffe-0.3-0.8.noarch"},{"parent_id":"repo_5","cols":{"1":{"id":1},"2":{"id":2}},"id":"package_a74c4bf4-9ffa-4080-bea7-dd2d575d1439","name":"walrus-0.3-0.8.noarch"},{"parent_id":"repo_5","cols":{"1":{"id":1},"2":{"id":2}},"id":"package_7837ae2e-feda-4e27-8c77-72502791cee5","name":"penguin-0.3-0.8.noarch"},{"parent_id":"repo_5","cols":{"1":{"id":1},"2":{"id":2}},"id":"package_30731359-7713-4f34-af5b-1ca5505587c3","name":"cheetah-0.3-0.8.noarch"},{"parent_id":"repo_5","cols":{"1":{"id":1},"2":{"id":2}},"id":"package_1cc74804-5e6d-4608-9ced-875ba26253af","name":"lion-0.3-0.8.noarch"},{"cols":{"1":{"id":1,"display":8238}},"id":"product_2","name":"Red Hat Enterprise Linux Server"},{"parent_id":"product_2","cols":{"1":{"id":1,"display":8238}},"id":"repo_85","name":"Red Hat Enterprise Linux 6 Server RPMs x86_64 6Server"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_8408fbc8-c18d-4979-afff-c9abdfcfc509","name":"apr-1.3.9-5.el6_2.i686"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_ab1d0ae3-e18e-4a6d-8a6c-453d8ca9f4ee","name":"apr-devel-1.3.9-3.el6.i686"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_c1b1f3ea-6fce-4ce8-a553-3619332eee37","name":"apr-devel-1.3.9-3.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_ee1ab73d-96ac-4efe-a960-cc1df0b2878c","name":"apr-devel-1.3.9-5.el6_2.i686"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_233d3ed4-8612-411a-9e48-db6f7a4e20c9","name":"apr-devel-1.3.9-5.el6_2.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_7d4c82b6-a49f-4388-aa9c-0b1bb35ffe57","name":"apr-util-1.3.9-3.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_9bb687d2-cde6-4cfe-891c-fe6534fcae98","name":"apr-util-devel-1.3.9-3.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_0170dfa6-80e8-480f-b675-72624e175138","name":"apr-util-devel-1.3.9-3.el6_0.1.i686"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_6853e411-9359-4ed9-ac3e-8fd762421dcf","name":"apr-util-devel-1.3.9-3.el6_0.1.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_0a96c69c-6bba-458c-98b3-c2650d377969","name":"apr-util-ldap-1.3.9-3.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_4868e337-6982-4665-afff-2e9351302ab9","name":"apr-util-ldap-1.3.9-3.el6_0.1.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_53ebf400-69a0-4779-9aa0-1dd09f92fd40","name":"arptables_jf-0.0.8-20.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_8d12095b-7549-4fb5-aea7-bb1ace3f6edd","name":"arts-1.5.10-10.el6.i686"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_926a3322-080c-4a76-b4a2-d01d917d3318","name":"arts-devel-1.5.10-10.el6.i686"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_c104c8cc-7707-4199-92c0-bc92128d64b5","name":"at-3.1.10-42.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_96b5b31c-3ee3-443b-bfeb-1b745fa07082","name":"at-3.1.10-43.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_5b9b1d95-4da9-4f58-a4f4-545b63401cbf","name":"atlas-3.8.3-12.4.el6.i686"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_a9d3a382-e027-4709-83e4-868e8fee5720","name":"atlas-3.8.4-1.el6.i686"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_4f03f76c-aec5-4bbb-9de7-071730d420aa","name":"atlas-sse3-3.8.4-2.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_4b32f71c-e0b1-4052-aaa4-ce07c5864e20","name":"audiofile-0.2.6-11.1.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_2278f83f-9ec5-4b5c-bbb0-35646f065b84","name":"audispd-plugins-2.1.3-3.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_1fc13efd-dc0b-42af-86d5-fbd7af7ae52b","name":"audit-2.1-5.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_63c369bf-b6bd-4c97-a89e-00eea8373ef0","name":"audit-libs-2.0.4-1.el6.i686"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_59484bad-e444-4ee6-acab-9d7897dae01d","name":"audit-libs-2.1-5.el6.x86_64"},{"parent_id":"repo_85","cols":{"1":{"id":1}},"id":"package_d6121090-b5f5-4777-9b1a-936048a2e52e","name":"audit-libs-2.2-2.el6.i686"},{"parent_id":"repo_85","current_count":25,"id":"repo_metadata_85","metadata":true,"data":{"repo_id":85},"total":8238,"page_size":25}]
