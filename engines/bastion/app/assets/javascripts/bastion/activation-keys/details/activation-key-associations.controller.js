/**
 * Copyright 2013-2014 Red Hat, Inc.
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
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyAssociationsController
 *
 * @requires $scope
 * @requires translate
 * @requires ActivationKey
 * @requires ContentHostsHelper
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for activation key associations.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyAssociationsController',
    ['$scope', 'translate', 'ActivationKey', 'ContentHostsHelper', 'CurrentOrganization',
    function ($scope, translate, ActivationKey, ContentHostsHelper, CurrentOrganization) {

        if ($scope.contentHosts) {
            $scope.table.working = false;
        } else {
            $scope.table.working = true;
        }

        $scope.activationKey.$promise.then(function () {
            ActivationKey.contentHosts({id: $scope.activationKey.id, 'organization_id': CurrentOrganization },
                function (response) {
                    $scope.contentHosts = response.results;
                    $scope.table.working = false;
                });
        });

        $scope.getStatusColor = ContentHostsHelper.getStatusColor;

        $scope.memory = ContentHostsHelper.memory;
    }]
);
