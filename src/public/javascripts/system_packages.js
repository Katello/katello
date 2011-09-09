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
    $('#more').bind('click', function(){
        KT.packages.morePackages();
    });
    $('#package_sort').bind('click', function(){
        KT.packages.reverseSort();
    });
});

KT.packages = (function(){
    return {
        morePackages : function(){
            var list = $('.packages');
            var more = $('#more');
            var spinner = $('#list-spinner');
            var dataScrollURL = more.attr("data-scroll_url");

            var offset = parseInt(more.attr("data-offset"), 10) + parseInt(more.attr("data-page_size"), 10);
            dataScrollURL = dataScrollURL + "?offset=" + offset + "&pkg_order="+ $('#package_sort').attr("data-sort") +"&";
            //console.log(dataScrollURL + ", page_size: " + offset);
            spinner.fadeIn();
            $.ajax({
                type: "GET",
                url: dataScrollURL,
                cache: false,
                success: function(data) {
                    KT.packages.retrievingNewContent = false;
                    spinner.fadeOut();
                    list.append(data);
                    $('#filter').keyup();
                    $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                    if (data.length == 0) {
                        more.empty().remove();
                    }else{
                        $('#more').attr("data-offset", offset);
                    }
                },
                error: function() {
                    spinner.fadeOut();
                    KT.packages.retrievingNewContent = false;
                }
            });
        },
        sortOrder : function(){
            var packageSort = $('#package_sort');
            var packageSortOrder = packageSort.attr("data-sort");
            if (packageSort.attr("data-sort") == "asc"){
                packageSortOrder = "desc";
                packageSort.removeClass("ascending").addClass("descending");
            } else {
                packageSortOrder = "asc";
                packageSort.removeClass("descending").addClass("ascending");
            }
            packageSort.attr("data-sort", packageSortOrder);
            return packageSortOrder;
        },
        reverseSort : function(){
            var list = $('.packages');
            var more = $('#more');
            var spinner = $('#list-spinner');
            var dataScrollURL = more.attr("data-scroll_url");
            var reverse = parseInt(more.attr("data-offset"), 10);

            dataScrollURL = dataScrollURL + "?reverse=" + reverse + "&pkg_order=" + KT.packages.sortOrder() + "&";
            spinner.fadeIn();
            list.find('tbody > tr').empty().remove();
            $.ajax({
                type: "GET",
                url: dataScrollURL,
                cache: false,
                success: function(data) {
                    KT.packages.retrievingNewContent = false;
                    spinner.fadeOut();
                    list.append(data);
                    $('#filter').keyup();
                    $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                    if (data.length == 0) {
                        more.empty().remove();
                    }else{
                        $('#more').attr("data-offset", reverse);
                    }
                },
                error: function() {
                    spinner.fadeOut();
                    KT.packages.retrievingNewContent = false;
                }
            });
        },
        retrievingNewContent : true
    }
})();
