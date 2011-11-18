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

KT.packages = function() {
    var system_id = $('.packages').attr('data-system_id'),
    retrievingNewContent = true,
    more_button = $('#more'),
    sort_button = $('#package_sort'),
    packages_form = $('#packages_form'),
    remove_button = $('#remove_packages'),
    update_button = $('#update_packages'),
    content_form = $('#content_form'),
    add_content_button = $('#add_content'),
    remove_content_button = $('#remove_content'),
    packages_radio_button = $('#perform_action_packages'),
    package_groups_radio_button = $('#perform_action_package_groups'),
    selected_checkboxes = 0,
    disableButtons = function() {
        remove_button.attr('disabled', 'disabled');
        update_button.attr('disabled', 'disabled');

        remove_button.addClass('disabled');
        update_button.addClass('disabled');
    },
    enableButtons = function() {
        remove_button.removeAttr('disabled');
        update_button.removeAttr('disabled');

        remove_button.removeClass('disabled');
        update_button.removeClass('disabled');
    },
    morePackages = function() {
        var list = $('.packages');
        var spinner = $('#list-spinner');
        var dataScrollURL = more_button.attr("data-scroll_url");

        var offset = parseInt(more_button.attr("data-offset"), 10) + parseInt(more_button.attr("data-page_size"), 10);
        dataScrollURL = dataScrollURL + "?offset=" + offset + "&pkg_order="+ sort_button.attr("data-sort") +"&";
        //console.log(dataScrollURL + ", page_size: " + offset);
        spinner.fadeIn();
        $.ajax({
            type: "GET",
            url: dataScrollURL,
            cache: false,
            success: function(data) {
                retrievingNewContent = false;
                spinner.fadeOut();
                list.append(data);
                registerCheckboxEvents();
                $('#filter').keyup();
                $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                if (data.length == 0) {
                    more_button.empty().remove();
                }else{
                    more_button.attr("data-offset", offset);
                }
            },
            error: function() {
                spinner.fadeOut();
                retrievingNewContent = false;
            }
        });
    },
    sortOrder = function() {
        var packageSortOrder = sort_button.attr("data-sort");
        if (sort_button.attr("data-sort") == "asc"){
            packageSortOrder = "desc";
            sort_button.removeClass("ascending").addClass("descending");
        } else {
            packageSortOrder = "asc";
            sort_button.removeClass("descending").addClass("ascending");
        }
        sort_button.attr("data-sort", packageSortOrder);
        return packageSortOrder;
    },
    reverseSort = function() {
        var list = $('.packages');
        var spinner = $('#list-spinner');
        var dataScrollURL = more_button.attr("data-scroll_url");
        var reverse = parseInt(more_button.attr("data-offset"), 10);

        dataScrollURL = dataScrollURL + "?reverse=" + reverse + "&pkg_order=" + KT.packages.sortOrder() + "&";
        spinner.fadeIn();
        list.find('tbody > tr.package').empty().remove();
        $.ajax({
            type: "GET",
            url: dataScrollURL,
            cache: false,
            success: function(data) {
                retrievingNewContent = false;
                spinner.fadeOut();
                list.append(data);
                registerCheckboxEvents();
                $('#filter').keyup();
                $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                if (data.length == 0) {
                    more_button.empty().remove();
                }else{
                    more_button.attr("data-offset", reverse);
                }
            },
            error: function() {
                spinner.fadeOut();
                retrievingNewContent = false;
            }
        });
    },
    registerCheckboxEvents = function() {
        var checkboxes = $('input[type="checkbox"]');
        checkboxes.unbind('change');
        checkboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")){
                    selected_checkboxes++;
                    enableButtons();
                }else{
                    selected_checkboxes--;
                    if(selected_checkboxes == 0){
                        disableButtons();
                    }
                }
            });
        });
    },
    registerEvents = function() {
        more_button.bind('click', morePackages);
        sort_button.bind('click', reverseSort);
        add_content_button.bind('click', addContent);
        remove_content_button.bind('click', removeContent);
        remove_button.bind('click', removePackages);
        update_button.bind('click', updatePackages);

        disableButtons();
        registerCheckboxEvents();
    },
    addContent = function(data) {
        data.preventDefault();
        var selected_action = $("input[@name=perform_action]:checked").attr('id');
        if (selected_action == 'perform_action_packages') {
            $.ajax({
                url: KT.routes.add_system_system_packages_path(system_id),
                type: 'PUT',
                data: {'packages' : content_form.find('#content_input').val()},
                cache: false
            });
        } else {
            $.ajax({
                url: KT.routes.add_system_system_packages_path(system_id),
                type: 'PUT',
                data: {'groups' : content_form.find('#content_input').val()},
                cache: false
            });
        }
    },
    removeContent = function(data) {
        var selected_action = $("input[@name=perform_action]:checked").attr('id');
        if (selected_action == 'perform_action_packages') {
            $.ajax({
                url: KT.routes.remove_system_system_packages_path(system_id),
                type: 'POST',
                data: {'packages' : content_form.find('#content_input').val()},
                cache: false
            });
        } else {
            $.ajax({
                url: KT.routes.remove_system_system_packages_path(system_id),
                type: 'POST',
                data: {'groups' : content_form.find('#content_input').val()},
                cache: false
            });
        }
    },
    removePackages = function(data) {
        data.preventDefault();
        disableButtons();
        packages_form.ajaxSubmit({
            url: remove_button.attr('data-url'),
            type: 'POST',
            success: function() {
                enableButtons();
            },
            error: function() {
                enableButtons();
            }
        });
    },
    updatePackages = function(data) {
        data.preventDefault();
        disableButtons();
        packages_form.ajaxSubmit({
            url: update_button.attr('data-url'),
            type: 'POST',
            success: function() {
                enableButtons();
            },
            error: function() {
                enableButtons();
            }
        });
    };
    return {
        morePackages: morePackages,
        sortOrder: sortOrder,
        reverseSort: reverseSort,
        registerEvents: registerEvents,
        addContent: addContent,
        removeContent: removeContent,
        removePackages: removePackages,
        updatePackages: updatePackages
    }
}();

$(document).ready(function() {
    KT.packages.registerEvents();
});