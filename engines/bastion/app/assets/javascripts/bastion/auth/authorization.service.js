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

    this.getCurrentUser = function () {
        return CurrentUser;
    };
}]);
