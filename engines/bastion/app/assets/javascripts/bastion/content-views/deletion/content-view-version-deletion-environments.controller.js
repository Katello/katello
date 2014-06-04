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
 * @name  Bastion.content-views.controller:ContentViewVersionDeletionEnvironments
 *
 * @requires $scope
 *
 * @description
 *   Provides the functionality for selecting which environments a user wants to remove
 *   a specific content view from.
 */
angular.module('Bastion.content-views').controller('ContentViewVersionDeletionEnvironmentsController',
    ['$scope',
    function ($scope) {
        $scope.environmentsTable = {rows: {}};
        $scope.version.$promise.then(function () {
            var numSelections;
            $scope.environmentsTable.rows = $scope.version.environments;
            if ($scope.version.environments.length === 0) {
                $scope.deleteOptions.deleteArchive = true;
            } else {
                angular.forEach($scope.environmentsTable.rows, function (row) {
                    row.unselectable = !row.permissions['promotable_or_removable'] ||
                                         !row.permissions['all_systems_editable'] ||
                                         !row.permissions['all_keys_editable'];
                });

                if ($scope.deleteOptions.environments.length === 0) {
                    //select all by default
                    angular.forEach($scope.environmentsTable.rows, function (row) {
                        row.selected = !row.unselectable;
                    });
                } else {
                    //set existing selections
                    angular.forEach($scope.environmentsTable.rows, function (row) {
                        row.selected = _.findWhere($scope.deleteOptions.environments,
                                                    {unselectable: false, id: row.id}) !== undefined;

                    });
                }

                numSelections = _.countBy($scope.environmentsTable.rows, function (row) {
                    return row.selected ? 'selected': 'unselected';
                });

                $scope.environmentsTable.numSelected = numSelections["selected"];
            }
        });

        $scope.canDeleteArchive = function () {
            return $scope.environmentsTable.numSelected === $scope.environmentsTable.rows.length;
        };

        $scope.selectionEmpty = function () {
            return !$scope.deleteOptions.deleteArchive && $scope.environmentsTable.numSelected === 0;
        };

        $scope.anySelectable = function () {
            return _.findWhere($scope.environmentsTable.rows, {unselectable: false}) !== undefined;
        };

        $scope.allSelectable = function () {
            return _.findWhere($scope.environmentsTable.rows, {unselectable: true}) === undefined;
        };

        $scope.processSelection = function () {
            $scope.deleteOptions.environments = $scope.environmentsTable.getSelected();
            $scope.transitionToNext();
        };

    }]
);
