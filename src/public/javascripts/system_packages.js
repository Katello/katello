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
    total_packages = $('.packages').attr('data-total_packages'),
    more_button = $('#more'),
    sort_button = $('#package_sort'),
    packages_form = $('#packages_form'),
    remove_button = $('#remove_packages'),
    update_button = $('#update_packages'),
    update_all_button = $('#update_all_packages'),
    content_form_row = $('#content_form_row'),
    content_form = $('#content_form'),
    add_content_button = $('#add_content'),
    remove_content_button = $('#remove_content'),
    loaded_summary = $('#loaded_summary'),
    add_row_shading = false,
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
    disableUpdateAll = function() {
        update_all_button.attr('disabled', 'disabled');
        update_all_button.addClass('disabled');
    },
    enableUpdateAll = function() {
        update_all_button.removeAttr('disabled');
        update_all_button.removeClass('disabled');
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
                updateLoadedSummary();
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
                updateLoadedSummary();
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
                    disableUpdateAll();
                }else{
                    selected_checkboxes--;
                    if(selected_checkboxes == 0){
                        disableButtons();
                        enableUpdateAll();
                    }
                }
            });
        });
    },
    initPackages = function() {
        registerEvents();
        disableButtons();
        enableUpdateAll();
        updateLoadedSummary();
    }
    registerEvents = function() {
        more_button.bind('click', morePackages);
        sort_button.bind('click', reverseSort);
        add_content_button.bind('click', addContent);
        remove_content_button.bind('click', removeContent);
        remove_button.bind('click', removePackages);
        update_button.bind('click', updatePackages);
        update_all_button.bind('click', updateAllPackages);

        registerCheckboxEvents();
    },
    addContent = function(data) {
        data.preventDefault();
        var selected_action = $("input[@name=perform_action]:checked").attr('id'),
            content_list = content_form.find('#content_input').val();
        if (selected_action == 'perform_action_packages') {
            $.ajax({
                url: KT.routes.add_system_system_packages_path(system_id),
                type: 'PUT',
                data: {'packages' : content_list},
                cache: false,
                success: function() {
                    packages = content_list.split(',');
                    for (i = 0; i < packages.length; i++) {
                        if (add_row_shading) {
                            add_row_shading = false;
                            content_form_row.after('<tr class="alt"><td></td><td>' + packages[i] + '</td><td><img style="padding-right:8px;" src="images/spinner.gif">' + i18n.adding_package + '</td></tr>');
                        }
                        else
                        {
                            add_row_shading = true;
                            content_form_row.after('<tr><td></td><td>' + packages[i] + '</td><td><img style="padding-right:8px;" src="images/spinner.gif">' + i18n.adding_package + '</td></tr>');
                        }
                    }
                },
                error: function() {
                }
            });
        } else {
            $.ajax({
                url: KT.routes.add_system_system_packages_path(system_id),
                type: 'PUT',
                data: {'groups' : content_list},
                cache: false,
                success: function() {
                    groups = content_list.split(',');
                    for (i = 0; i < groups.length; i++) {
                        if (add_row_shading) {
                            add_row_shading = false;
                            content_form_row.after('<tr class="alt"><td></td><td>' + groups[i] + '</td><td><img style="padding-right:8px;" src="images/spinner.gif">' + i18n.adding_group + '</td></tr>');
                        }
                        else
                        {
                            add_row_shading = true;
                            content_form_row.after('<tr><td></td><td>' + groups[i] + '</td><td><img style="padding-right:8px;" src="images/spinner.gif">' + i18n.adding_group + '</td></tr>');
                        }
                    }
                },
                error: function() {
                }
            });
        }
    },
    removeContent = function(data) {
        var selected_action = $("input[@name=perform_action]:checked").attr('id'),
            content_list = content_form.find('#content_input').val();
        if (selected_action == 'perform_action_packages') {
            $.ajax({
                url: KT.routes.remove_system_system_packages_path(system_id),
                type: 'POST',
                data: {'packages' : content_list},
                cache: false,
                success: function() {
                    packages = content_list.split(',');
                    for (i = 0; i < packages.length; i++) {
                        if (add_row_shading) {
                            add_row_shading = false;
                            content_form_row.after('<tr class="alt"><td></td><td>' + packages[i] + '</td><td><img style="padding-right:8px;" src="images/spinner.gif">' + i18n.removing_package + '</td></tr>');
                        }
                        else
                        {
                            add_row_shading = true;
                            content_form_row.after('<tr><td></td><td>' + packages[i] + '</td><td><img style="padding-right:8px;" src="images/spinner.gif">' + i18n.removing_package + '</td></tr>');
                        }
                    }
                },
                error: function() {
                }
            });
        } else {
            $.ajax({
                url: KT.routes.remove_system_system_packages_path(system_id),
                type: 'POST',
                data: {'groups' : content_list},
                cache: false,
                success: function() {
                    groups = content_list.split(',');
                    for (i = 0; i < groups.length; i++) {
                        if (add_row_shading) {
                            add_row_shading = false;
                            content_form_row.after('<tr class="alt"><td></td><td>' + groups[i] + '</td><td><img style="padding-right:8px;" src="images/spinner.gif">' + i18n.removing_group + '</td></tr>');
                        }
                        else
                        {
                            add_row_shading = true;
                            content_form_row.after('<tr><td></td><td>' + groups[i] + '</td><td><img style="padding-right:8px;" src="images/spinner.gif">' + i18n.removing_group + '</td></tr>');
                        }
                    }
                },
                error: function() {
                }
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
                // locate the selected packages and update the status column to indicate the action being performed
                $(':checkbox:checked').each( function() {
                    $(this).closest('.package').find('.package_action_status')
                        .html('<img style="padding-right:8px;" src="images/spinner.gif">' + i18n.removing_package);
                });
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
                // locate the selected packages and update the status column to indicate the action being performed
                $(':checkbox:checked').each( function() {
                    $(this).closest('.package').find('.package_action_status')
                        .html('<img style="padding-right:8px;" src="images/spinner.gif">' + i18n.updating_package);
                });
                enableButtons();
            },
            error: function() {
                enableButtons();
            }
        });
    },
    updateAllPackages = function(data) {
        data.preventDefault();
        disableButtons();
        $.ajax({
            url: update_button.attr('data-url'),
            type: 'POST',
            cache: false,
            success: function() {
                enableUpdateAll();
            },
            error: function() {
                enableUpdateAll();
            }
        });
    },
    updateLoadedSummary = function() {
        var total_loaded = $('tr.package').length,
            message = i18n.x_of_y_packages(total_loaded, total_packages);
        loaded_summary.html(message);
    };
    return {
        morePackages: morePackages,
        sortOrder: sortOrder,
        reverseSort: reverseSort,
        initPackages: initPackages,
        addContent: addContent,
        removeContent: removeContent,
        removePackages: removePackages,
        updatePackages: updatePackages,
        updateAllPackages: updateAllPackages
    }
}();

$(document).ready(function() {
    KT.packages.initPackages();
});
