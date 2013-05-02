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

$(document).ready(function () {
    var common_settings = {
        method: 'PUT',
        cancel: i18n.cancel,
        submit: i18n.save,
        indicator: i18n.saving,
        tooltip: i18n.clickToEdit,
        placeholder: i18n.clickToEdit,
        submitdata: $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
        onerror: function (settings, original, xhr) {
            original.reset();
            $("#notification").replaceWith(xhr.responseText);
            notices.checkNotices();
        }
    };
    // callback which fires product update, whether to update also related repositories is decided
    // by with_all_repos argument
    var update_product = function (element, result, with_all_repos) {
        $.ajax({
            type: 'PUT',
            url: element.data('url'),
            data: { 'product[gpg_all_repos]': with_all_repos,
                'product[gpg_key]': result },
            success: function (data) {
                notices.checkNotices();
            }
        });
    }


    $('.edit_select_product_gpg').each(function () {
        var element = $(this),
            settings = {
                type: 'select',
                name: element.attr('name'),
                data: element.data('options'),
                onsubmit: function () {
                    result = element.find('form select[name="product[gpg_key]"]').val();
                    var data = element.data('options');

                    data["selected"] = result;
                    element.html(data[result]);
                    if (result !== "") {
                        KT.common.customConfirm({
                            message: i18n.productUpdateKeyConfirm,
                            warning_message: i18n.productUpdateKeyWarning,
                            yes_callback: function () {
                                update_product(element, result, true)
                            },
                            no_callback: function () {
                                update_product(element, result, false)
                            }
                        });
                    }
                }
            };
        // we ignore default submit function by injecting empty function, all submitting is done
        // by onsubmit callback
        $(this).editable(function () {
        }, $.extend(common_settings, settings));
    });

});
