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
 */

/**
 * @ngdoc factory
 * @name  Bastion.factory:BastionResource
 *
 * @requires BastionResource
 *
 * @description
 *   Base module that defines the Katello module namespace and includes any thirdparty
 *   modules used by the application.
 */
angular.module('Bastion').factory('BastionResource', ['$resource', function ($resource) {

    return function (url, paramDefaults, actions, node) {
        var defaultActions;

        var unwrapResponse = function (data, headersGetter) {
            data = JSON.parse(data);
            if (data.results === undefined) {
                data = data[node];
            }

            return data;
        };

        var wrapRequest = function (data, headersGetter) {
            var transformed = {};

            transformed[node] = data;

            return JSON.stringify(transformed);
        };

        defaultActions = {
            queryPaged: {method: 'GET', isArray: false},
            queryUnpaged: {method: 'GET', isArray: false, params: {'full_result': true}}
        };

        actions = angular.extend({}, defaultActions, actions);

        angular.forEach(actions, function (action) {
            action.transformRequest = wrapRequest;
            action.transformResponse = unwrapResponse;
        });

        return $resource(url, paramDefaults, actions);
    };

}]);
