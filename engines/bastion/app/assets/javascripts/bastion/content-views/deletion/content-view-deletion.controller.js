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
 * @name  Bastion.content-views.controller:ContentViewDeletionController
 *
 * @requires $scope
 * @requires ContentView
 *
 * @description
 *   Provides the functionality for deleting Content Views
 */
angular.module('Bastion.content-views').controller('ContentViewDeletionController',
    ['$scope', 'ContentView', function ($scope, ContentView) {

        if ($scope.versions === undefined) {
            $scope.reloadVersions();
        }

        $scope.delete = function () {
            $scope.working = true;
            ContentView.remove({id: $scope.contentView.id}, success, failure);
        };

        $scope.conflictingVersions = function () {
            return _.reject($scope.versions, function (version) {
                return version.environments.length === 0;
            });
        };

        $scope.environmentNames = function (version) {
            return _.pluck(version.environments, 'name');
        };

        function success() {
            $scope.removeRow($scope.contentView.id);
            $scope.transitionTo('content-views.index');
            $scope.working = false;
        }

        function failure(response) {
            $scope.$parent.errorMessages = [response.data.displayMessage];
            $scope.working = false;
        }

    }]
);
