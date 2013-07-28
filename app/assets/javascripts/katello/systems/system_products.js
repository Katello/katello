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
/**
 * Created by .
 * User: jrist
 * Date: 7/13/11
 * Time: 2:27 PM
 *
 * This file is for use with the products subnav within systems page.
 */

$(document).ready(function() {
    $('#products_more').bind('click', function(){
        KT.products.moreProducts();
    });
    $('#products_sort').bind('click', function(){
        KT.products.reverseSort();
    });
});

KT.products = (function(){
    return {
        moreProducts : function(){
            var list = $('.products');
            var more = $('#products_more');
            var spinner = $('#list-spinner');
            var dataScrollURL = more.attr("data-scroll_url");

            var offset = parseInt(more.attr("data-offset"), 10);
            var page_size = parseInt(more.attr("data-page_size"), 10);
            var products_count = parseInt(more.attr("data-products_count"), 0);
            dataScrollURL = dataScrollURL + "?offset=" + offset + "&order="+ $('#products_sort').attr("data-sort") +"&";
            spinner.fadeIn();
            $.ajax({
                type: "GET",
                url: dataScrollURL,
                cache: false,
                success: function(data) {
                    KT.products.retrievingNewContent = false;
                    spinner.fadeOut();
                    list.append(data);
                    $('#filter').keyup();
                    $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                    offset = offset + page_size;
                    if (data.length === 0 || offset >= products_count) {
                        more.hide(); // Hide more button, but still use it to hold data
                    }
                    more.attr("data-offset", offset);
                },
                error: function() {
                    spinner.fadeOut();
                    KT.products.retrievingNewContent = false;
                }
            });
        },
        sortOrder : function(){
            var productSort = $('#products_sort');
            var productSortOrder = productSort.attr("data-sort");
            if (productSort.attr("data-sort") === "asc"){
                productSortOrder = "desc";
                productSort.removeClass("ascending").addClass("descending");
            } else {
                productSortOrder = "asc";
                productSort.removeClass("descending").addClass("ascending");
            }
            productSort.attr("data-sort", productSortOrder);
            return productSortOrder;
        },
        reverseSort : function(){
            var list = $('.products');
            var more = $('#products_more');
            var spinner = $('#list-spinner');
            var dataScrollURL = more.attr("data-scroll_url");
            var reverse = parseInt(more.attr("data-offset"), 10);

            dataScrollURL = dataScrollURL + "?reverse=" + reverse + "&order=" + KT.products.sortOrder() + "&";
            spinner.fadeIn();
            list.find('tbody > tr').empty().remove();
            $.ajax({
                type: "GET",
                url: dataScrollURL,
                cache: false,
                success: function(data) {
                    KT.products.retrievingNewContent = false;
                    spinner.fadeOut();
                    list.append(data);
                    $('#filter').keyup();
                    $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                    if (data.length === 0) {
                        more.empty().remove();
                    }else{
                        $('#products_more').attr("data-offset", reverse);
                    }
                },
                error: function() {
                    spinner.fadeOut();
                    KT.products.retrievingNewContent = false;
                }
            });
        },
        retrievingNewContent : true
    };
})();
