/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc service
 * @name Bastion.auth:Authorization
 *
 * @requires CurrentUser
 * @requires Permissions
 *
 * @description
 *   A service for authorization related functionality.
 */
angular.module('Bastion.auth').service('Authorization', ['CurrentUser', 'Permissions', function (CurrentUser, Permissions) {

    this.permitted = function (permissionName, model) {
        var allowedTo = false;

        if (CurrentUser.admin) {
            allowedTo = true;
        } else {
            if (model && model.hasOwnProperty('permissions') && model.permissions.hasOwnProperty(permissionName)) {
                allowedTo = model.permissions[permissionName];
            } else {
                angular.forEach(Permissions, function (permission) {
                    if (permission.permission.name === permissionName) {
                        allowedTo = true;
                    }
                });
            }
        }
        return allowedTo;
    };

    this.denied = function (permissionName, model) {
        return !this.permitted(permissionName, model);
    };
}]);
