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
var thisPanel  = null;
var subpanel = null;
var subpanelSpacing = 35;
var panelLeft = null;

$(document).ready(function() {
    $('.left').resize(function(){
        panelLeft = $(this).width();
        var apanel = $('.panel');
        $('.block').width(panelLeft-17);
        apanel.width(940-panelLeft);
        $('.right').width(910-panelLeft);
        if(apanel.hasClass('opened')){ apanel.css({"left":(panelLeft)}); }
        $('.left #new').css({"width":"10em"});
        $('.list-title').width(panelLeft);
        $('#list-title').width(panelLeft);
        var fontsize = Math.floor((panelLeft/430)*100);
        //if it's bigger than 100%, make it 100%.
        fontsize = (fontsize > 100) ? 100 : fontsize;
        $('#systems .block').css({"font-size": parseInt(fontsize, 10) + "%"});
    });
    $('.left').resize();

    //$('#list .block').linkHover({"timeout":200});
    thisPanel = $("#panel");
    subpanel = $('#subpanel');

    var activeBlock = null;
    var activeBlockId = null;
    var ajax_url = null;
    var original_top = Math.floor($('.left').position(top).top);
    var subpanel_top =  Math.floor($('.left').position(top).top + subpanelSpacing);

    $('#panel-frame').css({"top" : original_top});
    $('#subpanel-frame').css({"top" : subpanel_top});
    panel.panelResize($('#panel_main'), false);
    panel.panelResize($('#subpanel_main'), true);

    $('.block').live('click', function(e) {
        activeBlock = $(this);
        ajax_url = activeBlock.attr("data-ajax_url");
        activeBlockId = activeBlock.attr('id');

        if(e.ctrlKey && !thisPanel.hasClass('opened')) {
            if(activeBlock.hasClass('active')){activeBlock.removeClass('active');}
            else {
                activeBlock.addClass('active');
            }
        } else {
            if(activeBlock.hasClass('active')){ panel.closePanel(thisPanel); }
            else { $.bbq.pushState({panel:activeBlockId}); }
        }
        //update the selected count
        panel.updateResult();

        return false;
    });


    $('.close').live("click", function() {
        if($(this).attr("data-close") === "panel" ||
          ($(this).attr("data-close") !== "subpanel" && $(this).parent().parent().hasClass('opened'))) {
            panel.closePanel(thisPanel);
            panel.closeSubPanel(subpanel);
        }
        else {//closing the subpanel
            panel.closeSubPanel(subpanel);
        }
        return false;
    });
    
    $(window).resize(function(){
        panel.panelResize($('#panel_main'), false);
        panel.panelResize($('#subpanel_main'), true);
        panel.handleScrollResize($('#panel-frame'), container, original_top, bodyY, 0);
        panel.handleScrollResize($('#subpanel-frame'), container, subpanel_top, bodyY, 1);
    });

    $('#content').resize(function(){
        panel.panelResize($('#panel_main'), false);
        panel.panelResize($('#subpanel_main'), true);
    });

    $('.subpanel_element').live('click', function(){
        panel.openSubPanel($(this).attr('data-url'));
    });

  //  var floatingPanels = $('#panel-frame');
    var container = $('#container');
    if(container.length > 0){
        var bodyY = parseInt(container.offset().top, 10) - 20;
        $(window).scroll(function () {
            panel.handleScroll($('#panel-frame'), container, original_top, bodyY, 0);
            panel.handleScroll($('#subpanel-frame'), container, subpanel_top, bodyY, 1);
        });
        $(window).scroll(panel.scrollExpand);
    }

    // It is possible for the pane (e.g. right) of a panel to contain navigation
    // links.  When that occurs, it should be possible to click the navigation 
    // link and only that pane reflect the transition to the new page. The element
    // below helps to facilitate that by binding to the click event for a navigation
    // element with the specified id, sending a request to the server using the link
    // selected and then replacing the content of the pane with the response.
    $('.navigation_element > a').live('click', function ()
    {
        // if a view is a pane within a panel
        $.ajax({
            cache: 'false',
            type: 'GET',
            url: $(this).attr('href'),
            dataType: 'html',
            success: function(data) {
                $(".panel-content").html(data);
                panel.panelResize($('#panel_main'), false);
            }
        });
        return false;
    });

    $('.left').resizable({maxWidth: 550,
                                    minWidth: 300,
                                    grid: 25,
                                    handles: 'e',
                                    autoHide: true
                                  });
    $('.search').fancyQueries();

    //hash change for panel to trigger on refresh or back/forward or link passing
    $(window).bind( 'hashchange', panel.hash_change);
    $(window).trigger( 'hashchange' );

//end doc ready
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
           });
           return false;
       },
       complete_refresh: function(url) {
        $('#list').html('<img src="images/spinner.gif">');
        list.refresh("list", url);
       },
       refresh : function(id, url){
           var jQid = $('#' + id);
            $.ajax({
                cache: 'false',
                type: 'GET',
                url: url,
                dataType: 'html',
                success: function(data) {
                    notices.checkNotices();
                    jQid.html(data);
                }
            });
           return false;
       }
   };
})();

var panel = (function(){
    return {
        extended_cb : function() {}, //callback for post extended scroll
        expand_cb: function() {}, //callback after a pane is loaded
        select_item :    function(activeBlockId) {
            thisPanel = $("#panel");
            subpanel = $('#subpanel');

            var activeBlock = $('#' + activeBlockId);
            var ajax_url = activeBlock.attr("data-ajax_url");
            var previousBlockId = null;

            $('.block.active').removeClass('active');
            if(!thisPanel.hasClass('opened') && thisPanel.attr("data-id") !== activeBlockId){
                // Open the Panel                           /4
                thisPanel.animate({ left: (panelLeft) + "px", opacity: 1}, 200, function(){
                    $(this).css({"z-index":"200"});
                }).removeClass('closed').addClass('opened').attr('data-id', activeBlockId);
                activeBlock.addClass('active');
                previousBlockId = activeBlockId;
                panel.panelAjax(activeBlockId, ajax_url, thisPanel, false);
            } else if (thisPanel.hasClass('opened') && thisPanel.attr("data-id") !== activeBlockId){
                panel.closeSubPanel(subpanel); //close the subpanel if it is open
                // Keep the thisPanel open if they click another block
                // remove previous classes besides opened
                thisPanel.addClass('opened').attr('data-id', activeBlockId);
                $("#" + previousBlockId).removeClass('active');
                activeBlock.addClass('active');
                previousBlockId = activeBlockId;
                thisPanel.removeClass('closed');
                panel.panelAjax(activeBlockId, ajax_url, thisPanel, false);
            } else {
                // Close the Panel
                // Remove previous classes besides opened
                previousBlockId = activeBlockId;
                panel.closeSubPanel(subpanel);
                panel.closePanel(thisPanel);
            }
        },
        panelAjax : function(name, ajax_url, thisPanel, isSubpanel) {
            var spinner = thisPanel.find('.spinner');
            var panelContent = thisPanel.find(".panel-content");
            spinner.show();
            panelContent.hide();
            panel.expand_cb(name);
            
            $.ajax({
                cache: true,
                url: ajax_url,
                dataType: 'html',
                success: function (data, status, xhr) {
                    var pc = panelContent.html(data);
                    spinner.hide();
                    pc.fadeIn(function(){$(".panel-content :input:visible:enabled:first").focus();});
                    //panel.expand_cb(name);
                    if( isSubpanel ){
                        panel.panelResize($('#subpanel_main'), isSubpanel);
                    } else {
                        panel.panelResize($('#panel_main'), isSubpanel);
                    }
                },
                error: function (xhr, status, error) {
                    spinner.hide();
                    panelContent.html("<h2>Error</h2><p>There was an error retrieving that row: " + error + "</p>").fadeIn();

                }
            });
        },
        /* must pass a jQuery object */
        panelResize : function(paneljQ, isSubpanel){
            var new_top = Math.floor($('.left').position(top).top);
            var headerSpacing = $('.head').height() + $('.subnav').height();
            var height = $(window).height() - $('#subheader').height() - $('#head').height() - $('.subnav').height() - headerSpacing - 100;            
            
            new_top = isSubpanel ? (new_top + subpanelSpacing) : new_top;
            paneljQ.parent().animate({top: new_top}, 250);

            //if there is a lot in the list, make the panel a bit larger
            if ($('#content').height() > 642){
                var extraHeight =  common.height() - 192;
                if (isSubpanel) {
                    extraHeight -= subpanelSpacing;
                }
                paneljQ.height(extraHeight);
            } else {
                var leftPanel = $('.left');
                
                if( leftPanel.height() <= height + headerSpacing + 80){
                    height = leftPanel.height() - headerSpacing - 75;
                } else {
                    height += 110;
                }
                
                paneljQ.height(height);
            }
            if( paneljQ.length ){
                paneljQ.data('jsp').reinitialise();
            }
            return paneljQ;
        },
        closePanel : function(jPanel){
            var content = jPanel.find('.panel-content');
            $('.block.active').removeClass('active');
            jPanel.animate({
                left: 0,
                opacity: 0
            }, 400, function(){
                $(this).css({"z-index":"0"});
                $(this).parent().css({"z-index":"1"});
            }).removeClass('opened').addClass('closed').attr("data-id", "");
            content.html('');
            $.bbq.removeState("panel");
            panel.updateResult();
            panel.expand_cb(name);
            return false;
        },
        closeSubPanel : function(jPanel){
            if(jPanel.hasClass("opened")){
                jPanel.animate({
                    left: 0,
                    opacity: 0
                }, 400, function(){
                    $(this).css({"z-index":"0"});
                    $(this).parent().css({"z-index":"0"});
                }).removeClass('opened').addClass('closed');
                panel.updateResult();
            }
            panel.expand_cb(name);
            return false;
        },
        updateResult : function(){
            $('#select-result').html($('.block.active').length + " items selected.");
        },
        openSubPanel : function(url) {
            var thisPanel = $('#subpanel');
            thisPanel.animate({ left: panelLeft + "px", opacity: 1}, 200, function(){
                $(this).css({"z-index":"204"});
                $(this).parent().css({"z-index":"2"});
            }).removeClass('closed').addClass('opened');
            panel.panelAjax('', url, $('#subpanel-frame'), true);


        },
        retrievingNewContent : false,
        scrollExpand : function() { //If we are scrolling past the bottom, we need to request more data
            var list = $('#list');
            if (list.hasClass("ajaxScroll") && !panel.retrievingNewContent &&
                    $(window).scrollTop() >=  ($(document).height() - $(window).height()) - 700) {
                panel.retrievingNewContent = true;
                var offset = list.find(".block").size();
                var page_size = list.attr("data-page_size");
                if (parseInt(page_size) > parseInt(offset)) {
                    return; //If we have fewer items than the pagesize, don't try to fetch anything else
                }

                var url = list.attr("data-scroll_url")
                var search = $.deparam($.param.querystring()).search;
                var params = {"offset":offset}
                if (search)
                    params.search = search;
                
                list.append(jQuery('<div/>', {
                    'id': "list-spinner"
                }));
                $('#list-spinner').html( "<img src='/images/spinner.gif' class='ajax_scroll'>");

                $.ajax({
                    type: "GET",
                    url: jQuery.param.querystring(url, params),
                    cache: false,
                    success: function(data) {
                        var expand_list = $('.expand_list');
                        panel.retrievingNewContent = false;
                        expand_list.append(data);
                        $('#list-spinner').remove();
                        
                        if (data.length == 0) {
                            list.removeClass("ajaxScroll");
                        }
                        panel.extended_cb();
                    },
                    error: function() {
                        $('#list-spinner').remove();
                        panel.retrievingNewContent = false;
                    }
                });
            }
        },
        handleScroll : function(jQPanel, container, top, bodyY, spacing, offset) {
            var scrollY = common.scrollTop(),
                scrollX = common.scrollLeft(),
                isfixed = jQPanel.css('position') === 'fixed';
            
            offset = offset ? offset : 10;
            offset += $('#maincontent').offset().left;
            
            if(jQPanel.length > 0){
                if ( scrollY < bodyY    ) {
                    jQPanel.css({
                        position: 'absolute',
                        top: top,
                        left: ''
                    });
                } else {
                    jQPanel.stop().css({
                        position: 'fixed',
                        top: 40 + subpanelSpacing*spacing,
                        left: -scrollX + offset
                    });
                }
            }
        },
        handleScrollResize : function(jQPanel, container, top, bodyY, spacing, offset) {
            if(jQPanel.length > 0){
                if( jQPanel.css('position') === 'fixed'){
                    jQPanel.css('left', '');
                }
            }
        },
        hash_change: function() {
            var refresh = $.bbq.getState("panel");
            if(refresh){ 
                panel.select_item(refresh);
            }
            return false;
        }
    };

})();
