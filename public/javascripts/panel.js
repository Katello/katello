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

var count = 0;

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
        if( $(this).hasClass('column_panel_3') ){
            var fontsize = Math.floor((panelLeft/430)*100);
            //if it's bigger than 100%, make it 100%.
            fontsize = (fontsize > 100) ? 100 : fontsize;
            $('#systems .block').css({"font-size": parseInt(fontsize, 10) + "%"});
        }
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

    $('.block').live('click', function(event) {
        if( event.target.nodeName === "A" && event.target.className.match('content_add_remove') ){
            return false;
        } else {
	        activeBlock = $(this);
	        ajax_url = activeBlock.attr("data-ajax_url");
	        activeBlockId = activeBlock.attr('id');
	
	        if(event.ctrlKey && !thisPanel.hasClass('opened')) {
	            if(activeBlock.hasClass('active')){activeBlock.removeClass('active');}
	            else {
	                activeBlock.addClass('active');
	            }
	        } else {
	            if(activeBlock.hasClass('active')){ KT.panel.closePanel(thisPanel); }
	            else { $.bbq.pushState({panel:activeBlockId}); }
	        }
	        //update the selected count
	        KT.panel.updateResult();
	
	        return false;
        }
    });


    $('.close').live("click", function() {
        if($(this).attr("data-close") === "panel" ||
          ($(this).attr("data-close") !== "subpanel" && $(this).parent().parent().hasClass('opened'))) {
            KT.panel.closePanel(thisPanel);
            KT.panel.closeSubPanel(subpanel);
        }
        else {//closing the subpanel
            KT.panel.closeSubPanel(subpanel);
        }
        return false;
    });

    $(window).resize(function(){
        KT.panel.panelResize($('#panel_main'), false);
        KT.panel.panelResize($('#subpanel_main'), true);
    });

    $('.subpanel_element').live('click', function(){
        KT.panel.openSubPanel($(this).attr('data-url'));
    });

    var container = $('#container');
    if(container.length > 0){
    	KT.panel.registerPanel($('#panel-frame'), 0);
        $(window).scroll(KT.panel.scrollExpand);
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
                thisPanel.find(".panel-content").html(data);
                KT.panel.panelResize($('#panel_main'), false);
            }
        });
        return false;
    });

    $('.left').resizable({maxWidth: 550,
                                    minWidth: 350,
                                    grid: 25,
                                    handles: 'e',
                                    autoHide: true
                                  });
    $('.search').fancyQueries();

    if (KT.panel.control_bbq) {
        //hash change for panel to trigger on refresh or back/forward or link passing
        $(window).bind( 'hashchange', KT.panel.hash_change);
        $(window).trigger( 'hashchange' );
    }
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
       complete_refresh: function(url, success_cb) {
        $('#list').html('<img src="images/spinner.gif">');
        list.refresh("list", url, success_cb);
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

KT.panel = (function($){
	var retrievingNewContent= false,
	    control_bbq 		= true,
	    current_scroll 		= 0,
	    panels_list			= [],
	
		extended_cb         = function() {}, //callback for post extended scroll
        expand_cb           = function() {}, //callback after a pane is loaded
        contract_cb         = function() {},
        switch_content_cb   = function() {},
	
		select_item = function(activeBlockId) {
            var activeBlock = $('#' + activeBlockId),
            	ajax_url = activeBlock.attr("data-ajax_url"),
            	previousBlockId = null;
            	
            thisPanel = $("#panel");
            subpanel = $('#subpanel');

            if(!thisPanel.hasClass('opened') && thisPanel.attr("data-id") !== activeBlockId){
                $('.block.active').removeClass('active');
                // Open the Panel                           /4
                thisPanel.css({"z-index":"200"});
                thisPanel.parent().css({"z-index":"1"});
                thisPanel.animate({ left: (panelLeft) + "px", opacity: 1}, 200, function(){
                    //$(this).css({"z-index":"200"});
                }).removeClass('closed').addClass('opened').attr('data-id', activeBlockId);
                
                activeBlock.addClass('active');
                previousBlockId = activeBlockId;
                panelAjax(activeBlockId, ajax_url, thisPanel, false);
            } else if (thisPanel.hasClass('opened') && thisPanel.attr("data-id") !== activeBlockId){
                switch_content_cb();
                $('.block.active').removeClass('active');
                closeSubPanel(subpanel); //close the subpanel if it is open
                // Keep the thisPanel open if they click another block
                // remove previous classes besides opened
                thisPanel.addClass('opened').attr('data-id', activeBlockId);
                $("#" + previousBlockId).removeClass('active');
                activeBlock.addClass('active');
                previousBlockId = activeBlockId;
                thisPanel.removeClass('closed');
                panelAjax(activeBlockId, ajax_url, thisPanel, false);
            }
        },
        panelAjax = function(name, ajax_url, thisPanel, isSubpanel) {
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

                    spinner.hide();
                    pc.fadeIn(function(){$(".panel-content :input:visible:enabled:first").focus();});

                    if( isSubpanel ){
                        panelResize($('#subpanel_main'), isSubpanel);
                    } else {
                        panelResize($('#panel_main'), isSubpanel);
                    }
                    expand_cb(name);
                },
                error: function (xhr, status, error) {
                    spinner.hide();
                    panelContent.html("<h2>Error</h2><p>There was an error retrieving that row: " + error + "</p>").fadeIn();

                }
            });
        },
        /* must pass a jQuery object */
        panelResize = function(paneljQ, isSubpanel){
            if( paneljQ.length > 0 ){
		        adjustHeight(paneljQ, isSubpanel);
			}

            return paneljQ;
        },
        adjustHeight = function(paneljQ, isSubpanel){
        	var leftPanel 		= $('.left'),
            	tupane_panel 	= $('#panel'),
            	default_height	= 500,
            	new_top 		= Math.floor($('.list').offset().top - 60),
            	header_spacing	= tupane_panel.find('.head').height(),
            	subnav_spacing 	= tupane_panel.find('nav').height() + 10,
            	content_spacing = paneljQ.height(),
            	height 			= default_height - header_spacing - subnav_spacing,
            	panelFrame 		= paneljQ.parent().parent().parent().parent(),
            	extraHeight 	= 0,
            	window_height	= $(window).height(),
            	subpanelnav;
					
	            if( window_height <= (height + 80) && leftPanel.height() > 550 ){
	                height = window_height - 80 - header_spacing - subnav_spacing;
	            }
	
				if( isSubpanel ){
					subpanelnav = ($('#subpanel').find('nav').length > 0) ? $('#subpanel').find('nav').height() + 10 : 0;
					height = height - subpanelSpacing*2 - subpanelnav + subnav_spacing;
				}
	
	            paneljQ.height(height);
	            
	            if( paneljQ.length > 0 ){
	            	paneljQ.data('jsp').reinitialise();
	            }
        },
        closePanel = function(jPanel){
            var content = jPanel.find('.panel-content'),
            	position;
            
	        if(jPanel.hasClass("opened")){
                $('.block.active').removeClass('active');
                jPanel.animate({
                    left: 0,
                    opacity: 0
                }, 400, function(){
                    $(this).css({"z-index":"-1"});
                }).removeClass('opened').addClass('closed').attr("data-id", "");
                content.html('');
                
                position = KT.common.scrollTop();
                $.bbq.removeState("panel");
             	$(window).scrollTop(position);
                
                updateResult();
                contract_cb(name);
                closeSubPanel(subpanel);
            }
            return false;
        },
        closeSubPanel = function(jPanel){
            if(jPanel.hasClass("opened")){
                jPanel.animate({
                    left: 0,
                    opacity: 0
                }, 400, function(){
                    $(this).css({"z-index":"-1"});
                }).removeClass('opened').addClass('closed');
                updateResult();
            }
            
            return false;
        },
        updateResult = function(){
            $('#select-result').html($('.block.active').length + " items selected.");
        },
        openSubPanel = function(url) {
            var thisPanel = $('#subpanel');
            
            thisPanel.animate({ left: panelLeft + "px", opacity: 1}, 200, function(){
                $(this).css({"z-index":"204"});
                $(this).parent().css({"z-index":"2"});
            }).removeClass('closed').addClass('opened');
            
            panelAjax('', url, thisPanel, true);
        },
        scrollExpand = function() { //If we are scrolling past the bottom, we need to request more data
            var list = $('#list'),
            	offset = list.find(".block").size(),
            	page_size = list.attr("data-page_size"),
                url = list.attr("data-scroll_url"),
                search = $.deparam($.param.querystring()).search,
                params = {"offset":offset};
            
            if (list.hasClass("ajaxScroll") && !retrievingNewContent && 
            			$(window).scrollTop() >=  ($(document).height() - $(window).height()) - 700) {
                
                retrievingNewContent = true;

                if (parseInt(page_size) > parseInt(offset)) {
                    return; //If we have fewer items than the pagesize, don't try to fetch anything else
                }

                if (search)
                    params.search = search;
                
                list.append(jQuery('<div/>', {
                    'id': "list-spinner"
                }));
                $('#list-spinner').html( "<img src='images/spinner.gif' class='ajax_scroll'>");

                $.ajax({
                    type: "GET",
                    url: jQuery.param.querystring(url, params),
                    cache: false,
                    success: function(data) {
                        var expand_list = $('.expand_list');
                        
                        retrievingNewContent = false;
                        expand_list.append(data);
                        $('#list-spinner').remove();
                        
                        if (data.length == 0) {
                            list.removeClass("ajaxScroll");
                        }
                        extended_cb();
                    },
                    error: function() {
                        $('#list-spinner').remove();
                        retrievingNewContent = false;
                    }
                });
            }
        },
        handleScroll = function(jQPanel, offset) {
            var scrollY 	= KT.common.scrollTop(),
                scrollX 	= KT.common.scrollLeft(),
                isfixed 	= jQPanel.css('position') === 'fixed',
                container	= $('#container'),
                bodyY       = parseInt(container.offset().top, 10),
                left_panel 	= container.find('.left');
            
            top_position = left_panel.offset().top;
            
            offset = offset ? offset : 10;
            offset += $('#maincontent').offset().left;

            if(jQPanel.length > 0){
                if( left_panel.height() > 550 ){
                    if ( scrollY < bodyY ) {
                        jQPanel.css({
                            position: 'absolute',
                            top: top_position,
                            left: ''
                        });
                    } else {
                    	if( !isfixed && Math.abs(jQPanel.offset().top - $(window).scrollTop()) > 40){
	                        jQPanel.stop().css({
	                            position: 'fixed',
	                            top: 40,
	                            left: -scrollX + offset
	                        });                    		
                    	} else if( isfixed && ($('.left').offset().top + $('.left').height()) > (jQPanel.offset().top + jQPanel.height() + 40) ){
	                        jQPanel.stop().css({
	                            position: 'fixed',
	                            top: 40,
	                            left: -scrollX + offset
	                        });
                       } else {
	                       	jQPanel.css({
	                            position: 'absolute',
	                            top: ($('.left').offset().top + $('.left').height()) - jQPanel.height() - 40,
	                            left: ''
	                        });
                       }
                	}
                }
            }
        },
        handleScrollResize = function(jQPanel) {
            if(jQPanel.length > 0){
                if( jQPanel.css('position') === 'fixed'){
                    jQPanel.css('left', '');
                }
            }
        },
        hash_change = function(event) {
            var refresh = $.bbq.getState("panel");
            if(refresh){ 
                select_item(refresh);
            }
            return false;
        },
        registerPanel = function(jQPanel, offset){
        	var new_panel = {
        			panel	: jQPanel,
        			offset	: offset
        		};

        	$(window).scroll(function() {
            	handleScroll(jQPanel, offset);
        	});
	        $(window).resize(function(){
	        	handleScrollResize(jQPanel, offset);
	        });
        	        	    
			$(document).bind('helptip-closed', function(){
				handleScroll(jQPanel, offset);
			});			
			$(document).bind('helptip-opened', function(){
				handleScroll(jQPanel, offset);
			});

        	panels_list.push(new_panel);
        };
	
    return {
        set_extended_cb         : function(callBack){ extended_cb = callBack; },
        set_expand_cb           : function(callBack){ expand_cb = callBack; },
        set_contract_cb         : function(callBack){ contract_cb = callBack; },
        set_switch_content_cb	: function(callBack){ switch_content_cb = callBack; },
        select_item				: select_item,
        hash_change				: hash_change,
        handleScrollResize		: handleScrollResize,
        handleScroll			: handleScroll,
        scrollExpand			: scrollExpand,
        openSubPanel			: openSubPanel,
        updateResult			: updateResult,
        closeSubPanel			: closeSubPanel,
        closePanel				: closePanel,
        panelResize				: panelResize,
        adjustHeight			: adjustHeight,
        panelAjax				: panelAjax,
        control_bbq             : control_bbq,
        registerPanel			: registerPanel
    };

})(jQuery);
