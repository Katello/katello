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
 * @name  Bastion.system-groups.controller:SystemGroupDetailsInfoController
 *
 * @requires $scope
 *
 * @description
 *   Provides the functionality for the system group details action pane.
 */
angular.module('Bastion.system-groups').controller('SystemGroupDetailsInfoController',
    ['$scope', function ($scope) {

        $scope.limitTranslations = {"-1": "Unlimited"};
        $scope.isUnlimited = function (group) {
            return group['max_systems'] === -1;
        };

        $scope.unlimitedChanged = function () {
            if ($scope.isUnlimited($scope.group)) {
                $scope.group['max_systems'] = 1;
            } else {
                $scope.group['max_systems'] = -1;
            }
        };

    }]
);
