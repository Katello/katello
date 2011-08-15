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
/**
 * Created by .
 * User: jrist
 * Date: 7/13/11
 * Time: 2:27 PM
 *
 * This file is for use with the packages subnav within systems page.
 */

$(document).ready(function() {
    var theTable = $('table.packages');
    var filter = $('#filter');

    filter.keyup(function() {
        $.uiTableFilter(theTable, this.value);
    });
    filter.change(function(){filter.keyup()});

    //override the submit so it doesn't try to push a form
    $('#filter_form').submit(function () {
        filter.keyup();
        return false;
    }).focus(); //Give focus to input field
              /*
    var panel  = $('#panel');
    if(panel.length > 0){
        var bodyY = parseInt(container.offset().top, 10) - 20;
        $(this).scroll(function () {
            panel.handleScroll($('#panel-frame'), panel, original_top, bodyY, 0);
        });
        $(panel).scroll(packages.scrollExpand);
    }*/

    $('#more').live('click', function(){
        console.log("Awesome.");packages.morePackages()});
});

var packages = (function(){
    return {
        morePackages : function(){
            var list = $('.packages');
            var dataScrollURL = list.attr("data-scroll_url");
            var page_size = list.attr("data-page_size");
            console.log(dataScrollURL + ", page_size: " + page_size);
            list.parent().append($('<div/>', {
                'id': "list-spinner"
            }));
            $('#list-spinner').html( "<img src='/images/spinner.gif' class='ajax_scroll'>");

            $.ajax({
                type: "GET",
                //url: $.param.querystring(url, params),
                url: dataScrollURL,
                cache: false,
                success: function(data) {
                    var expand_list = $('.packages');
                    packages.retrievingNewContent = false;
                    expand_list.append(data);
                    $('#list-spinner').remove();
                    $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                    $('#more').fadeOut();
                    if (data.length == 0) {
                        list.removeClass("ajaxScroll");
                    }
                },
                error: function() {
                    $('#list-spinner').remove();
                    packages.retrievingNewContent = false;
                }
            });
        }
    }
})();