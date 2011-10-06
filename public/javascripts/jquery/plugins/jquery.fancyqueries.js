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

(function($){
  $.fn.fancyQueries = function () {
      /* Handle closing of dropdown if clicked outside */
      $(document).click(function (e) {
        //console.log(e.target);
        if(!( $(e.target).closest(".search").length ||
              $(e.target).hasClass("queryeditor") ||
              $(e.target).hasClass("showmore"))) {
          $(".qdropdown").hide();
          $(".queries").removeClass('open queryeditor');
        }
      });
      $('#search').click(function(e){$(document).click();});
    this.each(function () {
      var $qdropdown = $('.qdropdown', this);
      var searchbox = this;
      var menuurl = $(searchbox).attr("data-url");
      var $button;
      var offset = $(this).offset();
      var height = $(this).outerHeight();
      var width = $(this).outerWidth();
      /* Create Dropdown if it doesn't exist */
      if (!$qdropdown.length) {
        $qdropdown = $("<div class='qdropdown'></div>");
        $qdropdown.appendTo(this).hide();
      }
      /* Create button and resize the search input to show it */
      $button = $('<div class="queries"><span class="arrow"></span></div>"');
      $button.attr("data-url", menuurl);
      $button.appendTo($(this));
      $("input",this).css('margin-left', '24px');
      $("input",this).css('width', function () {
        width = $(this).width() - 24;
        return width;
      });
      /* Hook showing and hiding of the dropdown */
      $button.click(function () {
        if ($qdropdown.filter(":visible").length>0) {
          $qdropdown.hide(); //hides all menus, not just in this context
          $(".queries").removeClass('open queryeditor');
        } else {
          $('.qdropdown').hide(); //hide all first
          $(".queries").removeClass('open queryeditor');
  
          $.get(menuurl, function (data) {
            var $list, hidden, $hideme;
            $qdropdown.html(data).css('top', height - 1);
            if ($qdropdown.width()+offset.left > $('#maincontent').width()) {
              $qdropdown.removeClass('left-menu').addClass('right-menu');
            } else {
              $qdropdown.removeClass('right-menu').addClass('left-menu');
            }

            $qdropdown.show(200);

            // process the elements of the list and truncate any that are too long with ellipsis (...) (e.g. jquery.text-overflow.js)
            $(".one-line-ellipsis").ellipsis();

            $button.addClass('open');
            $list = $("ul:first", $qdropdown);
            $("li.item:gt(9)", $list).hide();
            hidden = $("li.item:hidden",$list).length;
            if (hidden) {
              $hideme = $('<a class="showmore">Show '+ hidden + ' more</a>');
              $('#search_list').append($hideme);
              $hideme.click(function (e) {
                e.preventDefault();
                $("li.item", $list).show();
                $(this).remove(); //for some reason remove triggers a click or something.
              });
            }
          });
        }
      });

      /* Query Editor */
      $(".queryeditor", $qdropdown[0]).live('click', function (e) {
        var content = '<h1>Query Editor</h1>';
        content += "<div><h2>FIXME</h2>";
        content += "<p style='width: 400px; min-height: 100px;'>Initially I think this would provide help on how to compose a query. Once we have a better idea on what the queries look like, a gui editor.</p>" +
                "<a href='#' onclick='$(document).click()'>Close</a></div>";
        $button.removeClass('open').addClass('queryeditor');
        $qdropdown.empty().hide().addClass('queryeditor').html(content);
        if ($qdropdown.width()+offset.left > $('#maincontent').width()) {
              $qdropdown.removeClass('left-menu').addClass('right-menu');
            } else {
              $qdropdown.removeClass('right-menu').addClass('left-menu');
        }
        $qdropdown.show(200);
      });
    });
  };
})(jQuery);
