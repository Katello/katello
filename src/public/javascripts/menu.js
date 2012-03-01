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

/*
 * Katello JavaScript Menu File
 * Author: jrist
 * Date: 10/25/11
 * Time: 10:19 AM
 */

/**
 * Document Ready function
 */
$(document).ready(function (){
  KT.menu.menuSetup();
  KT.menu.thirdLevelNavSetup();
});

KT.menu = (function(){
  return {
    menuSetup: function(){
      //set some useful vars
      var topLevel = $('nav.tab_nav li.top_level');
      var activeSubnav = $('nav.tab_nav .second_level').filter(".selected").parent();
      var secondLevel = $('nav.tab_nav .second_level').parent();
      var subnav = $('#subnav');

      var activeTab = topLevel.filter('.selected:visible');

      //hide the secondlevel before prepending it to subnav
      secondLevel.hide();
      //set the current tab to active so we can check it later
      activeTab.addClass('active');
      activeTab = topLevel.filter('.active');
      //move (prepend) the second level nav items to subnav

      secondLevel.each(function(){
      	if( activeTab.attr('id') !== $(this).parent().attr('id') ){
      		$(this).prependTo(subnav);
      	} else {
      		$(this).remove();
      	}
      });

      //some settings for the hoverable top level tabs
      var hoverSettings = {
        sensitivity: 4,
        interval: 50,
        timeout: 350,
        over: function(){
          $(this).trigger("open");
        },
        out: function(){
          $(this).trigger("close.menu");
        }
      };

      //for each top level menu item tab, attach a hoverIntent event and bind another event
      topLevel.each(function(){
        var topLevelTab = $(this);
        var tabType = topLevelTab.attr('data-menu');
        var currentSubnav = subnav.find('.' + tabType + '.second_level').parent();
        var enter = function(){topLevelTab.trigger("mouseenter");};
        var leave = function(){topLevelTab.delay("800").trigger("mouseout")};
        currentSubnav.hover(function(){enter()},function(){leave()});
        
        topLevelTab.bind("open", function(){
            //make the tab "highlight" on hover
            $(this).addClass('selected');
            activeSubnav.hide();
            //show the current subnav and trigger it to stay open
            currentSubnav.slideDown('fast');
            topLevelTab.trigger("hovering");
          }).bind("hovering", function(){
            currentSubnav.show();
          })
          .bind("close.menu", function(){
            //take away tab highlight
            $(this).removeClass('selected');
            activeTab.addClass('selected');
            activeSubnav.show();
            if(!$(this).hasClass('active')) {
              //the stuff to do to if it's not the current tab
              currentSubnav.slideUp('fast');
            }
          }).hoverIntent(hoverSettings);

      });
    },
    thirdLevelNavSetup : function(){
        var children = $('.third_level:first-child');

        $.each(children, function(i, item) {
            KT.menu.hoverMenu(item);
        });
    },
    hoverMenu : function(element, options){
	    var child = $(element);
        var li = child.parent().parent();
        var ul = child.parent();
        var options = options || {};
        
        if( options.top ){
        	ul.css('top', options.top);
        }
        if(li.find(".arrow_icon_menu").length === 0) {
            li.prepend($('<div class="arrow_icon_menu"></div>'));
        }

        li.hoverIntent(
            function(){
              ul.addClass("third_level").slideDown('fast');
            },
            function(){
              ul.slideUp('fast').removeClass("third_level");
        });
        li.mouseenter().mouseleave();
    }
  };
})();
