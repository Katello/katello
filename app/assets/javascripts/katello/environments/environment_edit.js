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

$(document).ready(function() {
    $('.edit_env_name').each(function() {
        var button = $(this);

        $(this).editable(button.attr('data-url'), {
            type        :  'text',
            width       :  270,
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            submitdata  :  {authenticity_token: AUTH_TOKEN},
            onsuccess   :  function() {
              KT.panel.panelAjax('', button.attr("data-forward") ,$('#panel'));
            },
            onerror     :  function(settings, original, xhr) {
              original.reset();
              $("#notification").replaceWith(xhr.responseText);
            }
        });
    });

    $('.edit_prior_envs').each(function() {
        var button = $(this);
        $(this).editable(button.attr('data-url'), {
            type        :  'select',
            width       :  440,
            method      :  'PUT',
            name        :  $(this).attr('name'),
            cancel      :  i18n.cancel,
            submit      :  i18n.save,
            indicator   :  i18n.saving,
            tooltip     :  i18n.clickToEdit,
            placeholder :  i18n.clickToEdit,
            style       :  "inherit",
            data        :  document.environment_edit.elements['prior_envs'].value,
            onsuccess   :  function() {
                KT.panel.panelAjax('', button.attr("data-forward") ,$('#panel'));
            },
            onerror     :  function(settings, original, xhr) {
                original.reset();
                $("#notification").replaceWith(xhr.responseText);
            }
        });
    });

});
