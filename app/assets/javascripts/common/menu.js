/**
 Copyright 2013 Red Hat, Inc.

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
});

KT.menu = (function(){
  return {
    menuSetup: function(){
      //set some useful vars
      var topLevel = $('#appnav li.top_level');
      var secondLevel = $('#subnav').find('ul');
      var activeSubnav = secondLevel.find(".selected").first().parent();
      var subnav = $('#subnav');

      var activeTab = topLevel.filter('.selected:visible');

      //hide the secondlevel before prepending it to subnav
      secondLevel.not(activeSubnav).hide();
      //set the current tab to active so we can check it later
      activeTab.addClass('active');
      activeTab = topLevel.filter('.active');

      //append the arrow icon to all menus with a third level
      var parents = $('li.menu_parent');
      parents.prepend($('<div class="arrow_icon_menu"></div>'));
      parents.each(function(i, a_parent){
        var this_parent = $(a_parent);
        var parent_menu_name = this_parent.data('dropdown');
        $("li[dropdown='" + parent_menu_name +"']").first().parent().appendTo(this_parent);
        KT.menu.hoverMenu(a_parent);
      });


      //some settings for the hoverable top level tabs
      var hoverSettings = {
        sensitivity: 2,
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
            if(!$(this).hasClass('active')) {
                $(this).removeClass('selected');
                activeTab.addClass('selected');
                activeSubnav.show();
              //the stuff to do to if it's not the current tab
              currentSubnav.slideUp('fast');
            }
          }).hoverIntent(hoverSettings);

      });
    },
    hoverMenu : function(element, options){
      var li = $(element);
      if (!(li.children().first().hasClass('arrow_icon_menu'))){
        //append the arrow icon to all menus with a third level
        li.prepend($('<div class="arrow_icon_menu"></div>'));
      }
      var ul = li.find('ul');
      options = options || {};

      if( options.top ){
        ul.css('top', options.top);
      }

      li.hoverIntent(
          function(){
            $(document).mouseup();
            ul.addClass("third_level").slideDown('fast');
          },
          function(){
            ul.slideUp('fast').removeClass("third_level");
      });
      li.mouseenter().mouseleave();
    }
  };
})();
