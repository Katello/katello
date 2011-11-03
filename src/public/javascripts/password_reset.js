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
KT.password_reset = function() {
    var getLogins = function(data) {
        data.ajaxSubmit();
    },
    submitPasswordResetRequest = function (data) {
        data.ajaxSubmit();
    },
    registerEvents = function() {
        $('#request_logins').live('submit', function(e) {
            e.preventDefault();
            getLogins($(this));
        });
        $('#request_password_reset').live('submit', function (e) {
            e.preventDefault();
            submitPasswordResetRequest($(this));
        })
    };
    return {
        registerEvents: registerEvents
    }
}(jQuery);

$(document).ready(function() {
    KT.password_reset.registerEvents();
});
