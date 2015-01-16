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
 * @name  Bastion.content-hosts.factory:ContentHostErratum
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for the errata of a single content host
 */
angular.module('Bastion.content-hosts').factory('ContentHostErratum',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/v2/systems/:id/errata/:errata_id/:action', {id: '@uuid'}, {
            get: {method: 'GET', isArray: false, transformResponse: function (data) {
                data = angular.fromJson(data);
                angular.forEach(data.results, function (errata) {
                    errata.unselectable = !errata.installable;
                });
                return data;
            }},
            apply: {method: 'PUT', params: {action: 'apply'}}
        });

    }]
);
