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
      secondLevel.prependTo(subnav);

      //some settings for the hoverable top level tabs
      var hoverSettings = {
        sensitivity: 4,
        interval: 50,
        timeout: 100,
        over: function(){
          $(this).trigger("open");
        },
        out: function(){
          $(this).trigger("close");
        }
      };

      //for each top level menu item tab, attach a hoverIntent event and bind another event
      topLevel.each(function(){
        var topLevelTab = $(this);
        var tabType = topLevelTab.attr('data-menu');
        var currentSubnav = subnav.find('.' + tabType + '.second_level').parent();
        var enter = function(){topLevelTab.trigger("mouseenter");};
        var leave = function(){setTimeout(topLevelTab.trigger("mouseout"), 200)};
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
          .bind("close", function(){
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
            var child = $(item);
            var li = child.parent().parent();
            var  ul = child.parent();

            li.prepend($('<div class="arrow_icon_menu"></div>'));
            li.hover(
                function(){
                    ul.slideDown('fast');
                },
                function(){
                    ul.slideUp('fast');
            });
        });

    }
  };
})();