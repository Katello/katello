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
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionDetailsInfoController
 *
 * @requires $scope
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionDetailsInfoController',
    ['$scope', function ($scope) {

        $scope.limitTranslations = {"-1": "Unlimited"};
        $scope.isUnlimited = function (hostCollection) {
            return hostCollection['max_content_hosts'] === -1;
        };

        $scope.unlimitedChanged = function () {
            if ($scope.isUnlimited($scope.hostCollection)) {
                $scope.hostCollection['max_content_hosts'] = 1;
            } else {
                $scope.hostCollection['max_content_hosts'] = -1;
            }
        };

    }]
);
