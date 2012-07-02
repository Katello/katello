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
//some variables that are used throughout the panel
var thisPanel = null;
var subpanel = null;
var subpanelSpacing = 55;
var panelLeft = null;
var count = 0;

// Saves the state of the last subpanel viewed so selecting a new item from list will keep that subpanel open.
var last_ajax_panelpage;

$(document).ready(function () {
    $('.left').resize(function () {
        var apanel = $('.panel');
        panelLeft = $(this).width();
        $('.block').not('#new').width(panelLeft - 17);
        apanel.width(940 - panelLeft);
        $('.right').width(898 - panelLeft);
        if (apanel.hasClass('opened')) {
            apanel.css({
                "left": (panelLeft)
            });
        }
        $('.list-title').width(panelLeft);
        $('#list-title').width(panelLeft);
        if ($(this).hasClass('column_panel_3')) {
            var fontsize = Math.floor((panelLeft / 430) * 100);
            //if it's bigger than 100%, make it 100%.
            fontsize = (fontsize > 100) ? 100 : fontsize;
            $('#systems .block').css({
                "font-size": parseInt(fontsize, 10) + "%"
            });
        }
    }).resize();
    //$('#list .block').linkHover({"timeout":200});
    thisPanel = $("#panel");
    subpanel = $('#subpanel');
    var activeBlock = null;
    var activeBlockId = null;
    var ajax_url = null;
    var panel_selected;

    $('.block').live('click', function (event) {
        var subpanel_href,
            subpanel_name,
            ajax_panelpage;

        if (event.target.nodeName === "A" && event.target.className.match('content_add_remove')) {
            return false;
        } else {
            activeBlock = $(this);
            ajax_url = activeBlock.attr("data-ajax_url");
            activeBlockId = activeBlock.attr('id');
            ajax_panelpage = activeBlock.attr("data-ajax_panelpage");

            // If the panel is currently open, get the currently open tab
            if (thisPanel.hasClass('opened')) {
                subpanel_href = $('.panel_link.selected > a').attr('href');
                if (subpanel_href) {
                    last_ajax_panelpage = subpanel_href.substr(subpanel_href.lastIndexOf('/') + 1);
                }
            }

            if(event.ctrlKey && !thisPanel.hasClass('opened') && !(event.target.id == "new") && !activeBlock.hasClass('active')) {
                if (activeBlock.hasClass('active')) {
                    activeBlock.removeClass('active');
                } else {
                    activeBlock.addClass('active');
                    activeBlock.find('.arrow-right').hide();
                }
            } else if (event.ctrlKey && !thisPanel.hasClass('opened') && !(event.target.id == "new") && activeBlock.hasClass('active') && $('.block.active').length > 1) {
              activeBlock.removeClass('active');
            } else {
                if(activeBlock.hasClass('active') && thisPanel.hasClass('opened')){
                    KT.panel.closePanel(thisPanel);
                } else {
                    if (ajax_panelpage && !last_ajax_panelpage) {
                        last_ajax_panelpage = ajax_panelpage;
                    }
                    if (last_ajax_panelpage) {
                        $.bbq.pushState({
                            panel: activeBlockId,
                            panelpage: last_ajax_panelpage
                        });
                    } else {
                        $.bbq.pushState({
                            panel: activeBlockId
                        });
                    }
                    activeBlock.find('.arrow-right').show();
                }
            }
            //update the selected count
            KT.panel.updateResult();
            return false;
        }
    });
    $('.close').live("click", function () {
        if ($(this).attr("data-close") === "panel" || ($(this).attr("data-close") !== "subpanel" && $(this).parent().parent().hasClass('opened'))) {
            KT.panel.closePanel(thisPanel);
            KT.panel.closeSubPanel(subpanel);
        }
        else { //closing the subpanel
            KT.panel.closeSubPanel(subpanel);
        }
        return false;
    });
    $(window).resize(function () {
        KT.panel.panelResize($('#panel_main'), false);
        KT.panel.panelResize($('#subpanel_main'), true);
    });
    $('.subpanel_element').live('click', function () {
        KT.panel.openSubPanel($(this).attr('data-url'));
    });

    // It is possible for the pane (e.g. right) of a panel to contain navigation
    // links.  When that occurs, it should be possible to click the navigation
    // link and only that pane reflect the transition to the new page. The element
    // below helps to facilitate that by binding to the click event for a navigation
    // element with the specified id, sending a request to the server using the link
    // selected and then replacing the content of the pane with the response.
    $('.panel_link > a').live('click', function () {
        // if a view is a pane within a panel
        $.ajax({
            cache: 'false',
            type: 'GET',
            url: $(this).attr('href'),
            dataType: 'html',
            success: function (data) {
                var callbacks = KT.panel.get_expand_cb(),
                    cb = function(){};

                thisPanel.find(".panel-content").html(data);
                KT.common.jscroll_init($('.scroll-pane'));
                KT.common.jscroll_resize($('.jspPane'));
                KT.panel.panelResize($('#panel_main'), false);

                // Update the bbq
                var activeBlock = $('#' + KT.common.escapeId(activeBlockId)),
                    ajax_url = activeBlock.attr("data-ajax_url"),
                    ajax_panelpage = activeBlock.attr("data-ajax_panelpage");

                if (ajax_panelpage) {
                    // Replace old ajax_panelpage with new
                    ajax_panelpage = this.url.substr(this.url.lastIndexOf('/') + 1);
                    var bbq_panel = $.bbq.getState("panel");
                    $.bbq.removeState("panel");
                    $.bbq.removeState("panelpage");
                    $.bbq.pushState({
                        panel: bbq_panel,
                        panelpage: ajax_panelpage
                    });
                    // Set the new default panelpage
                    last_ajax_panelpage = ajax_panelpage;
                }

                for( cb in callbacks ){
                    callbacks[cb]();
                }
            }
        });
        return false;
    });
    $('.left').resizable({
        maxWidth: 550,
        minWidth: 350,
        grid: 25,
        handles: 'e',
        autoHide: true
    });

    //register a common select none action
    KT.panel.actions.registerAction("select_none", {});
    $('#select-none').mouseup(function(){
        $('.block.active').removeClass('active');
        KT.panel.updateResult();
    });
    //create the initial selected count
    KT.panel.updateResult();
    //register the default actions for the page's actions partial
    KT.panel.actions.registerDefaultActions();


});

var list = (function(){
   return {
       last_child : function() {
         return $("#list").children().last();
       },
       add : function(html) {
           $('#list').append($(html).hide().fadeIn(function(){
               $(this).addClass("add", 250, function(){
                   $(this).removeClass("add", 250);
               });
           }));
           return false;
       },
       remove : function(id){
           $('#' + id).fadeOut(function(){
               $(this).empty().remove();
               KT.panel.updateResult();
           });
           return false;
       },
       refresh : function(id, url, success_cb){
           var jQid = $('#' + id);
            $.ajax({
                cache: 'false',
                type: 'GET',
                url: url,
                dataType: 'html',
                success: function(data) {
                    notices.checkNotices();
                    jQid.html(data);
                    if (success_cb) {
                        success_cb();
                    }
                }
            });
           return false;
       }
   };
})();

$(window).ready(function(){
    if ($('#container').length > 0) {
        KT.panel.registerPanel($('#panel-frame'), 0);
    }
    KT.panel.actions.resetActions();
});
KT.panel = (function ($) {
    var retrievingNewContent= false,
        control_bbq = true,
        current_scroll = 0,
        panels_list = [],
        left_list_content = "",
        expand_cb = [],
        search = undefined,
        //callback after a pane is loaded
        contract_cb = function () {},
        switch_content_cb = function () {},
        select_item = function (activeBlockId) {
            var activeBlock = $('#' + KT.common.escapeId(activeBlockId)),
                ajax_url = activeBlock.attr("data-ajax_url"),
                ajax_panelpage = activeBlock.attr("data-ajax_panelpage"),
                full_ajax_url,
                previousBlockId = null;

            if (ajax_panelpage) {
                // Initialize the default panelpage
                if (!last_ajax_panelpage) {
                    last_ajax_panelpage = ajax_panelpage;
                }
                full_ajax_url = ajax_url + '/' + last_ajax_panelpage;
            } else {
                full_ajax_url = ajax_url;
            }

            thisPanel = $("#panel");
            subpanel = $('#subpanel');
            if (activeBlock.length) {
                if (!thisPanel.hasClass('opened') && thisPanel.attr("data-id") !== activeBlockId) {
                    $('.block.active').removeClass('active');
                    // Open the Panel                           /4

                    handleScroll($('#panel-frame'));

                    thisPanel.css({
                        "z-index": "200"
                    });
                    thisPanel.parent().css({
                        "z-index": "20"
                    });
                    thisPanel.animate({
                        left: (panelLeft) + "px",
                        opacity: 1
                    }, 200, function () {
                        $(this).css({
                            "z-index": "200"
                        });
                    }).removeClass('closed').addClass('opened').attr('data-id', activeBlockId);
                    activeBlock.addClass('active');
                    previousBlockId = activeBlockId;
                    panelAjax(activeBlockId, full_ajax_url, thisPanel, false);
                }
                else if (thisPanel.hasClass('opened') && thisPanel.attr("data-id") !== activeBlockId) {
                    switch_content_cb();
                    $('.block.active').removeClass('active');
                    closeSubPanel(subpanel); //close the subpanel if it is open
                    // Keep the thisPanel open if they click another block
                    // remove previous classes besides opened
                    thisPanel.css({
                        "z-index": "200"
                    });
                    thisPanel.parent().css({
                        "z-index": "20"
                    });
                    thisPanel.addClass('opened').attr('data-id', activeBlockId);
                    $("#" + previousBlockId).removeClass('active');
                    activeBlock.addClass('active');
                    previousBlockId = activeBlockId;
                    thisPanel.removeClass('closed');
                    panelAjax(activeBlockId, full_ajax_url, thisPanel, false);
                }
            }
        },
        panelAjax = function (name, ajax_url, thisPanel, isSubpanel) {
            var spinner = thisPanel.find('.spinner'),
                panelContent = thisPanel.find(".panel-content");
            spinner.show();
            panelContent.hide();
            $.ajax({
                cache: true,
                url: ajax_url,
                dataType: 'html',
                success: function (data, status, xhr) {
                    var pc = panelContent.html(data);
                    var callback;
                    spinner.hide();
                    pc.fadeIn(function () {
                        $(".panel-content :input:visible:enabled:first").focus();
                    });

                    KT.common.jscroll_init($('.scroll-pane'));
    				        KT.common.jscroll_resize($('.jspPane'));

                    if (isSubpanel) {
                        panelResize($('#subpanel_main'), isSubpanel);
                    } else {
                        panelResize($('#panel_main'), isSubpanel);
                    }

                    for( callback in expand_cb ){
                    	expand_cb[callback](name);
                    }
                    // Add a handler for ellipsis
                    $(".one-line-ellipsis").ellipsis(true);
                },
                error: function (xhr, status, error) {
                    spinner.hide();
                    panelContent.html("<h2>" + i18n.error + "</h2><p>" + i18n.row_error + error + "</p>").fadeIn();
                }
            });
        },
        /* must pass a jQuery object */
        panelResize = function (paneljQ, isSubpanel) {
            if (paneljQ.length > 0) {
                adjustHeight(paneljQ, isSubpanel);
            }
            return paneljQ;
        },
        adjustHeight = function (paneljQ, isSubpanel) {
            var leftPanel = $('.left'),
                tupane_panel = $('#panel'),
                new_top = Math.floor($('.list').offset().top - 60),
                header_spacing = tupane_panel.find('.head').height(),
                subnav_spacing = tupane_panel.find('nav').height() + 10,
                content_spacing = paneljQ.height(),
                panelFrame = paneljQ.parent().parent().parent().parent(),
                tupane_header = $('.tupane_header').height() || 0,
                tupane_footer = $('.tupane_footer').height() || 0,
                extraHeight = 0,
                window_height = $(window).height(),
                container_offset = $('#container').offset().top,
                subpanelnav,
                height,
                default_height = 565,
                default_spacing = header_spacing + subnav_spacing + tupane_header + tupane_footer + 30;

            if (window_height <= (height + 80) && leftPanel.height() > 550) {
                height = window_height - container_offset - default_spacing;
            } else if( leftPanel.height() > 575 ){
                if( leftPanel.height() < window_height ){
                    height = leftPanel.height() - default_spacing;
                } else {
                    height = window_height - container_offset - default_spacing;
                }
            } else {
                height = default_height - default_spacing + 20;
            }
            if (isSubpanel) {
                subpanelnav = ($('#subpanel').find('nav').length > 0) ? $('#subpanel').find('nav').height() + 10 : 0;
                height = height - subpanelSpacing * 2 - subpanelnav + subnav_spacing;
            }

            paneljQ.height(height);

            if (paneljQ.length > 0) {
                paneljQ.data('jsp').reinitialise();
            }
        },
        closePanel = function (jPanel) {
            var jPanel = jPanel || $('#panel'),
                content = jPanel.find('.panel-content'),
                position;
            if (jPanel.hasClass("opened")) {
                $('.block.active').removeClass('active');
                jPanel.animate({
                    left: 0,
                    opacity: 0
                }, 400, function () {
                    $(this).css({
                        "z-index": "-1"
                    });
                }).removeClass('opened').addClass('closed').attr("data-id", "");
                content.html('');
                position = KT.common.scrollTop();
                $.bbq.removeState("panel");
                $.bbq.removeState("panelpage");
                $(window).scrollTop(position);
                updateResult();
                contract_cb(name);
                closeSubPanel(subpanel);
            }
            return false;
        },
        closeSubPanel = function (jPanel) {
            if (jPanel.hasClass("opened")) {
                jPanel.animate({
                    left: 0,
                    opacity: 0
                }, 400, function () {
                    $(this).css({
                        "z-index": "-1"
                    });
                    $(this).removeClass('opened').addClass('closed');
                });
                updateResult();
            }
            return false;
        },
        updateResult = function(){
            //calc the number of active tupane rows
            var len = $('.block.active').length;
            //update the select
            $('#select-result').html(len + i18n.items_selected).effect("highlight", {}, 200);
            $('.numitems').html(len).effect("highlight", {}, 200);
            actions.resetActions(len);
            return len;
        },
        getSelected = function() {
            var to_ret = [];
            $('.block.active').each(function(){
                var id = $(this).attr("id");
                to_ret.push(id.split("_")[1]);
            });
            return to_ret;
        },
        numSelected = function() {
            return $('.block.active').length;
        },
        openSubPanel = function (url) {
            var thisPanel = $('#subpanel');
            thisPanel.animate({
                left: panelLeft + "px",
                opacity: 1
            }, 200, function () {
                $(this).css({
                    "z-index": "204"
                });
                $(this).parent().css({
                    "z-index": "2"
                });
                $(this).removeClass('closed').addClass('opened');
            });
            panelAjax('', url, thisPanel, true);
        },
        handleScroll = function (jQPanel, offset) {
            var scrollY = KT.common.scrollTop(),
                scrollX = KT.common.scrollLeft(),
                isFixed = jQPanel.css('position') === 'fixed',
                container = $('#container'),
                bodyY = parseInt(container.position().top, 10),
                left_panel = container.find('.left'),
                left_bottom_pos = left_panel.offset().top + left_panel.height(),
                top;

            top_position = left_panel.offset().top;
            offset = offset ? offset : 10;
            offset += $('#maincontent .maincontent').offset().left;
            offset -= scrollX;

            if (jQPanel.length > 0) {
                if (scrollY <= container.offset().top) {
                    top = (container.offset().top - scrollY <= 30 && container.offset().top - scrollY >= -30) ? 30 : top_position - scrollY;

                    jQPanel.css({
                        position: 'fixed',
                        top: top,
                        left: offset
                    });
                }
                else {
                    if ( left_bottom_pos - (jQPanel.offset().top + jQPanel.height()) <= 40 ) {
                        jQPanel.css({
                            position: 'fixed',
                            top: (left_bottom_pos - jQPanel.height()) - scrollY,
                            left: offset
                        });
                    } else {
                        jQPanel.stop().css({
                            position: 'fixed',
                            top: 30,
                            left: offset
                        });
                    }
                }
            }
        },
        handleScrollResize = function (jQPanel, offset) {
            var scrollX = KT.common.scrollLeft();

            offset = offset ? offset : 10;
            offset += $('#maincontent .maincontent').offset().left;
            offset -= scrollX;

            if (jQPanel.length > 0) {
                if (jQPanel.css('position') === 'fixed') {
                    jQPanel.css('left', offset);
                }
            }
        },
        search_started = function (event, promise) {
            var refresh = $.bbq.getState("panel");
            if (!last_ajax_panelpage) {
                last_ajax_panelpage = $.bbq.getState("panelpage");
            }

            if (refresh) {
                if (promise) {
                    closePanel();
                    promise.done(function(){
                        $('.left').resize();
                        select_item(refresh);
                    });
                }
                else {
                    select_item(refresh);
                }
            }
            else {
                closePanel();
            }
            return false;
        },
        registerPanel = function (jQPanel, offset) {
            var new_panel = {
                panel: jQPanel,
                offset: offset
            };
            $(window).scroll(function (event) {
                if( event.target === document){
                    handleScroll(jQPanel, offset);
                }
            });
            $(window).resize(function () {
                handleScrollResize(jQPanel, offset);
            });
            $(document).bind('helptip-closed', function () {
                handleScroll(jQPanel, offset);
            });
            $(document).bind('helptip-opened', function () {
                handleScroll(jQPanel, offset);
            });
            panels_list.push(new_panel);
        },
        registerSubPanelSubmit = function(form_id, form_submit_id) {
            form_id.bind('ajax:beforeSend', function(){
               form_submit_id.addClass('disabled');
            }).bind("ajax:complete", function(){
               form_submit_id.removeClass('disabled');
            }).bind("ajax:success", function(){
                KT.panel.closeSubPanel($('#subpanel'));
                KT.panel.refreshPanel();
            }).bind("ajax:error", function(){
               //validation notice appears
            });
        },
        // http://devnull.djolley.net/2010/11/accessing-query-string-parameters-from.html
        queryParameters = function () {
            var queryString = new Object;
            var qstr = window.location.search.substring(1);
            var params = qstr.split('&');
            $.each(params, function(index, item){
                var pair=item.split('=');
                if(pair[1]) {
                    queryString[pair[0]]=decodeURI(pair[1]);
                }
            });
            return queryString;
        },
        refreshPanel = function() {
          var active = $('#list').find('.active');
          KT.panel.panelAjax(active, active.attr("data-ajax_url"), $('#panel'), false);
        },
        actions = (function(){
            var action_list = {},
                current_request_action = undefined;

            var registerDefaultActions = function() {
                var actions = $(".panel_action");
                actions.each(function(index){
                    var action = $(this);
                    var options = action.find(".options");
                    action.find(".request_action").click(function() {
                        var params = action_list[action.attr("data-id")],
                            valid = true;

                        current_request_action = $(this);
                        if(params.valid_input_cb) {
                            // Has the user provided valid input for the request?
                            valid = params.valid_input_cb(current_request_action);
                        }
                        if (valid && !action.hasClass("disabled")) {
                            options.slideDown('fast');
                        }
                    });
                    action.find(".cancel").click(function() {
                        if ($(this).hasClass("disabled")){return}
                        options.slideUp('fast');
                    });
                    action.find(".trigger").click(function() {
                        var params = action_list[action.attr("data-id")];
                        var success = function() {
                            options.slideUp('fast');
                            action.find("input").removeClass("disabled");
                            if (params.success_cb){
                                params.success_cb(getSelected());
                            }
                        };
                        var error = function() {
                          action.find("input").removeClass("disabled");
                          if(params.error_cb) {
                              params.error_cb(getSelected());
                          }
                        };

                        if ($(this).hasClass("disabled")){return}

                        if(params.ajax_cb) {
                            params.ajax_cb(getSelected(), current_request_action, options);
                        }
                        else {
                            $.ajax({
                                cache: 'false',
                                type: params.method,
                                url: params.url,
                                data: {ids:getSelected()},
                                success: success,
                                error: error
                            });
                        }
                        if (getSelected() === 0) {
                            action.find("input").addClass("disabled");
                        }
                    });
                });
                updateResult();
            },
            registerAction = function(name, params) {
                /**
                 * params:
                 *    success_cb(data, selected_ids)
                 *    error_cb(data, selected_ids)
                 *    url      //URL for ajax call
                 *    method   //METHOD for ajax call
                 *    unselected_action // true if the action is 'doable' even if
                 *    ajax_cb(id_list, request_action, options, success_cb, error_cb)  //To manually do the ajax call yourself
                 *    valid_input_cb() // to validate the input for the request... return true if valid; otherwise, false
                 *    enable_cb()  // callback to provide custom initialization logic when 1 or more elements are selected
                 *    disable_cb() // callback to provide custom logic when all elements are cleared (i.e. select none)
                 */
              action_list[name] = params;
            },
            resetActions = function(num) {
              $.each(action_list, function(name, params){
                  if(!params.unselected_action) {
                    var div = $("[data-id=" + name + "]");
                    if (num > 0) {
                        div.removeClass("disabled");
                        if (params.enable_cb) {
                            params.enable_cb();
                        }
                    }
                    else {
                        div.addClass("disabled");
                        if (params.disable_cb) {
                            params.disable_cb();
                        }
                    }
                  }
              });
              var actions = $(".panel_action");
              actions.each(function(index){
                var action = $(this);
                action.find('.cancel').click();
              });
            };

            return {
                registerAction: registerAction,
                registerDefaultActions: registerDefaultActions,
                resetActions: resetActions
            }
        })();
    return {
        set_expand_cb: function (callBack) {
            expand_cb.push(callBack);
        },
        get_expand_cb: function () {
            return expand_cb;
        },
        set_contract_cb: function (callBack) {
            contract_cb = callBack;
        },
        set_switch_content_cb: function (callBack) {
            switch_content_cb = callBack;
        },
        select_item: select_item,
        numSelected: numSelected,
        search_started: search_started,
        openSubPanel: openSubPanel,
        updateResult: updateResult,
        closeSubPanel: closeSubPanel,
        closePanel: closePanel,
        panelResize: panelResize,
        panelAjax: panelAjax,
        control_bbq: control_bbq,
        registerPanel: registerPanel,
        registerSubPanelSubmit: registerSubPanelSubmit,
        queryParameters: queryParameters,
        refreshPanel : refreshPanel,
        actions: actions,
        handleScroll : handleScroll
    };
})(jQuery);

KT.panel.list = (function () {
    var total_items_count = 0,
        current_items_count = 0,
        results_items_count = 0,
        search,
        list_section = $('#list section'),
        
        update_counts = function (current, total, results, clear) {
            if (clear) {
                current_items_count = current;
                total_items_count = total;
                results_items_count = results;
            }
            else {
                current_items_count += current;
                total_items_count += total;
                results_items_count += results;
            }
            $('#total_items_count').html(total_items_count);
            $('#current_items_count').html(current_items_count);
            $('#total_results_count').html(results_items_count);
        },
        last_child = function () {
            return list_section.children().last();
        },
        first_child = function () {
            return list_section.children().first();
        },
        append = function (html) {
            list_section.append($(html).hide().fadeIn(function () {
                list_section.addClass("add", 250, function () {
                    list_section.removeClass("add", 250);
                });
            }));
            return false;
        },
        prepend = function (html) {
            list_section.prepend($(html).hide().fadeIn(function () {
                list_section.addClass("add", 250, function () {
                    list_section.removeClass("add", 250);
                });
            }));
            return false;
        },
        remove = function (id) {
            $('#' + id).fadeOut(function () {
                $(this).empty().remove();
                update_counts(-1, -1, -1);
            });
            return false;
        },
        current_count = function(){
            return current_items_count;
        },
        replace_list = function(html) {
            var list_elem = $("#list");

            list_elem.find('.spinner').hide();
            list_section.html(html).show();
        },
        full_spinner = function() {
            var list_elem = $("#list");
            list_section.empty();
            list_elem.find('.spinner').show();
        },
        refresh = function (id, url, success_cb) {
            var jQid = $('#' + id);
            $.ajax({
                cache: 'false',
                type: 'GET',
                url: url,
                dataType: 'html',
                success: function (data) {
                    notices.checkNotices();
                    jQid.html(data);
                    // Obtain the value from column_1 and place it in pane_heading. This is
                    // to accommodate changes to an item's name, for example, and have it
                    // dynamically update in both left list and the right title.
                    //
                    // Unless an explicit #heading_title element exists, use the first div
                    // (which was the previous default behavior).
                    var heading_title = jQid.find('#heading_title');
                    if (heading_title.length == 0) {
                        heading_title = jQid.children('div:first');
                    }
                    $('.pane_heading').html(heading_title.html());
                    if (success_cb) {
                        success_cb();
                    }
                }
            });
            return false;
        },
        registerPage = function (resource_type, options) {
            options = options || {};
            
            search = KT.search("search_form", "list", this,
                {url: $("#list").attr("data-scroll_url")}, options['extra_params']);


            $(document).bind(search.search_event(), KT.panel.search_started);


            if (KT.panel_search_autocomplete){
              search.enableAutoComplete({data:KT.panel_search_autocomplete});
            }

            $(window).trigger('hashchange');

            KT.panel.control_bbq = false;


            $(document).ready(function () {
                if (options['extra_params']) {
                    for (var i = 0; i < options['extra_params'].length; i += 1) {
                        options['extra_params'][i]['init_func']();
                    }
                }
                $(window).trigger('hashchange', [true]);
            });
            
            if (options['create']) {
                $('#' + options['create']).live('submit', function (e) {
                    var button = $(this).find('input[type|="submit"]'),
                        data = KT.common.getSearchParams() || {},
                        validation = options['validation'] || function(){ return true; };
                                           
                    e.preventDefault();

                    if( options['extra_create_data'] ){
                        $.extend(data, options['extra_create_data']() );
                    }

                    if( validation() ){
                        button.attr("disabled", "disabled");
                        
                        $(this).ajaxSubmit({
                            url: KT.routes[resource_type + '_path'](),
                            data: data,
                            success: createSuccess,
                            error: function (e) {
                                button.removeAttr('disabled');
                                notices.checkNotices();
                            }
                        });
                    }
                });
            }
        },
        createSuccess = function(data){
        	var id;

            if (data['no_match']) {
                KT.panel.closePanel($('#panel'));
                notices.checkNotices();
                update_counts(0, 0, 1);
            }
            else {
                prepend(data);
                KT.panel.closePanel($('#panel'));
                id = first_child().attr("id");

                if (last_ajax_panelpage) {
                    $.bbq.pushState({
                        panel: id,
                        panelpage: last_ajax_panelpage
                    });
                } else {
                    $.bbq.pushState({
                        panel: id
                    });
                }
                KT.panel.select_item(id);
                notices.checkNotices();
                update_counts(1, 1, 1);
            }
        };
    return {
        extended_event	: function () { if(search){search.extend_event()} },
        registerPage	: registerPage,
        createSuccess	: createSuccess,
        remove			: remove,
        refresh			: refresh,
        append		    : append,
        replace_list    : replace_list,
        update_counts   : update_counts,
        full_spinner    : full_spinner,
        current_count   :  current_count
    };
})();
