/**
 * Copyright 2013 Red Hat, Inc.
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
 * @ngdoc controller
 * @name  Katello.controller:SystemsController
 *
 * @requires $scope
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality specific to Systems for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Katello').controller('SystemsController',
    ['$scope', 'Nutupane', 'Routes',
    function($scope, Nutupane, Routes) {

        var nutupane = new Nutupane();

        $scope.table                = nutupane.table;
        $scope.table.url            = Routes.api_systems_path();
        $scope.table.activeItem    = {};
        $scope.table.modelName      = "Systems";

        nutupane.get();

        nutupane.defaultItemUrl = function(id) {
            return Routes.edit_system_path(id);
        };

        $scope.selectItem = function(id) {
            nutupane.selectItem(KT.routes.edit_system_path(id), id);
        }

        $scope.getStatusColor = function(status) {
            var color = '';

            if (status === 'valid') {
                color = 'green';
            } else if (status === 'partial') {
                color = 'yellow';
            } else {
                color = 'red';
            }

            return color;
        };

        /**
         * Fill the right pane with the specified state.
         * @param state the state to fill the right pane with.
         */
        $scope.fillActionPaneWithState = function(state) {
            $scope.table.setDetailsVisibility(false);
            $scope.table.openActionPane();
            $state.transitionTo(state);
        };
    }]
);

/**
 * @ngdoc controller
 * @name  Katello.systems.controller:SystemsBulkActionController
 *
 * @requires $scope
 * @requires $http
 * @requires SystemGroups
 * @requires Nutupane
 * @requires Routes
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the systems page.
 */
angular.module('Katello.systems').controller('SystemsBulkActionController',
    ['$scope', '$http', 'SystemGroups', 'Nutupane', 'Routes', 'CurrentOrganization',
    function($scope, $http, SystemGroups, Nutupane, Routes, CurrentOrganization) {
        var systemGroups = [];

        var nutupane                       = new Nutupane();
        $scope.systemGroups                = nutupane.table;
        $scope.systemGroups.url            = Routes.api_organization_system_groups_path(CurrentOrganization);
        $scope.systemGroups.transform      = transform;
        $scope.systemGroups.model          = 'System Groups';
        $scope.systemGroups.active_item    = {};
        $scope.working = false;

        nutupane.get();

        $scope.addSystemsToGroups = function() {
            $scope.working = true;
            var getIdFromRow = function(row) {
                return row.row_id;
            };
            var selectedSystemGroupRows = $scope.systemGroups.get_selected_rows();
            var systemIds = $.map($scope.table.get_selected_rows(), getIdFromRow);
            var systemGroupIds = $.map(selectedSystemGroupRows, getIdFromRow);
            var data = {group_ids: systemGroupIds, ids:systemIds};

            $http.post(Routes.bulk_add_system_group_systems_path(), data).then(function(response) {
                $scope.working = false;
                // Work around AngularJS not providing direct access to the XHR object
                response.getResponseHeader = response.headers;
                notices.checkNoticesInResponse(response);

                // Update the count of systems for each system group
                if (response.status === 200) {
                    var selectedSystemNames = $.map($scope.systems, function(system) {
                        if (systemIds.indexOf(system.id) >= 0) {
                            return system.name;
                        }
                    });
                    var selectedSystemGroups = $.map(systemGroups, function(systemGroup) {
                        if (systemGroupIds.indexOf(systemGroup.id) >= 0) {
                            return systemGroup;
                        }
                    });

                    // TODO refactor this by providing direct access to the $scope model in alch-tables
                    $.each(selectedSystemGroups, function(groupIndex, systemGroup) {
                        $.each(selectedSystemNames, function(systemIndex, systemName) {
                            if (systemGroup.system.indexOf(systemName) === -1) {
                                systemGroup.system.push(systemName);
                                $.each(selectedSystemGroupRows[groupIndex].cells, function(cellIndex, cell) {
                                    if (cell.column_id === "num_systems") {
                                        cell.display = systemGroup.system.length;
                                    }
                                });
                            }
                        });
                    });
                }
            });
        };
    }]
);
