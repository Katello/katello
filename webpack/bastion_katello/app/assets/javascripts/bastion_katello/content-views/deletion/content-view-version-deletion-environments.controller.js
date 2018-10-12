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
                                         !row.permissions['all_hosts_editable'] ||
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
                        row.selected = angular.isDefined(_.find($scope.deleteOptions.environments, {unselectable: false, id: row.id}));

                    });
                }

                numSelections = _.countBy($scope.environmentsTable.rows, function (row) {
                    return row.selected ? 'selected' : 'unselected';
                });

                $scope.environmentsTable.numSelected = numSelections.selected;
            }
        });

        $scope.canDeleteArchive = function () {
            return $scope.environmentsTable.numSelected === $scope.environmentsTable.rows.length;
        };

        $scope.selectionEmpty = function () {
            return !$scope.deleteOptions.deleteArchive && $scope.environmentsTable.numSelected === 0;
        };

        $scope.anySelectable = function () {
            var anySelectable;
            if ($scope.environmentsTable.rows.length === 0) {
                anySelectable = true;
            } else {
                anySelectable = angular.isDefined(_.find($scope.environmentsTable.rows, {unselectable: false}));
            }
            return anySelectable;
        };

        $scope.allSelectable = function () {
            return angular.isUndefined(_.find($scope.environmentsTable.rows, {unselectable: true}));
        };

        $scope.processSelection = function () {
            $scope.deleteOptions.environments = $scope.environmentsTable.getSelected();
            $scope.transitionToNext();
        };

    }]
);
