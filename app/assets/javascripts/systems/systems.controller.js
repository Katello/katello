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
 * @requires $location
 * @requires $compile
 * @requires $http
 * @requires $state
 * @requires Routes
 *
 * @description
 *   Provides the functionality specific to Systems for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Katello.systems').controller('SystemsController',
    ['$scope', 'Nutupane', '$location', '$compile', '$filter', '$http', '$state', 'Routes',
    function($scope, Nutupane, $location, $compile, $filter, $http, $state, Routes) {

        var columns = [{
            id: 'name',
            display: 'Name',
            show: true
        },{
            id: 'description',
            display: 'Description',
            show: true
        },{
            id: 'environment',
            display: 'Environment',
            show: true
        },{
            id: 'content_view',
            display: 'Content View',
            show: true
        },{
            id: 'created_at',
            display: 'Created at',
            show: true
        },{
            id: 'updated_at',
            display: 'Updated at',
            show: true
        }];

        var transform = function(data) {
            var rows = [];

            angular.forEach(data.systems,
                function(system) {
                    var row = {
                        'row_id' : system.id,
                        'show'  : true,
                        'cells': [{
                            display: $compile('<a ng-click="table.select_item(\'' + Routes.edit_system_path(system.id) + '\',' + system.id + ')">' + system.name + '</a>')($scope),
                            column_id: 'name'
                        },{
                            display: system.description,
                            column_id: 'description'
                        },{
                            display: system.environment.name,
                            column_id: 'environment'
                        },{
                            display: system.content_view ? system.content_view.name : "",
                            column_id: 'content_view'
                        },{
                            display: $filter('date')(system.created_at, 'medium'),
                            column_id: 'created_at'
                        },{
                            display: $filter('date')(system.updated_at, 'medium'),
                            column_id: 'updated_at'
                        }]
                    };
                    rows.push(row);
                });

            return {
                rows    : rows,
                total   : data.total,
                subtotal: data.subtotal
            };
        };

        var nutupane                = new Nutupane();

        $scope.table                = nutupane.table;
        $scope.table.url            = Routes.api_systems_path();
        $scope.table.transform      = transform;
        $scope.table.model          = 'Systems';
        $scope.table.data.columns   = columns;
        $scope.table.active_item    = {};

        nutupane.setColumns([columns[0]]);

        $scope.createNewSystem = function () {
            var createSuccess = function (data) {
                $scope.$apply(function () {
                    nutupane.table.setNewItemVisibility(false);
                    $scope.table.select_item(Routes.edit_system_path(data.system.id));
                });
                notices.checkNotices();
            };

            // Temporarily get the old new systems UI
            // TODO REPLACE ME
            $http.get(Routes.new_system_path()).then(function (response) {
                var content = $('#nutupane-new-item .nutupane-pane-content'),
                    data = KT.common.getSearchParams() || {},
                    button = content.find('input[type|="submit"]');

                content.html(response.data);
                nutupane.table.setDetailsVisibility(false);
                nutupane.table.setNewItemVisibility(true);

                content.find('#new_system').submit(function (event) {
                    event.preventDefault();
                    $(this).ajaxSubmit({
                        url: Routes.systems_path(),
                        data: data,
                        success: createSuccess,
                        error: function (e) {
                            button.removeAttr('disabled');
                            notices.checkNotices();
                        }

                    });
                });
            });
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

        nutupane.default_item_url = function(id) {
            return Routes.edit_system_path(id);
        };

        nutupane.get(function() {
            if ($location.search().item) {
                $scope.table.select_item(undefined, $location.search().item);
            }
        });
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
        var columns = [{
            id: 'name',
            display: 'Name',
            show: true
        },{
            id: 'max_systems',
            display: 'Maximum Systems',
            show: true
        },{
            id: 'num_systems',
            display: 'Num Systems',
            show: true
        }];

        var transform = function(data) {
            var rows = [];

            angular.forEach(data['system_groups'],
                function(systemGroup) {
                    var row = {
                        'row_id' : systemGroup.id,
                        'show'  : true,
                        'cells': [{
                            display: systemGroup.name,
                            column_id: 'name'
                        },{
                            display: systemGroup.max_systems,
                            column_id: 'max_systems'
                        },{
                            display: systemGroup.system.length,
                            column_id: 'num_systems'
                        }]
                    };
                    rows.push(row);
                }
            );

            return {
                rows    : rows,
                total   : data.total,
                subtotal: data.subtotal
            };
        };

        var nutupane                       = new Nutupane();
        $scope.systemGroups                = nutupane.table;
        $scope.systemGroups.url            = Routes.api_organization_system_groups_path(CurrentOrganization);
        $scope.systemGroups.transform      = transform;
        $scope.systemGroups.model          = 'System Groups';
        $scope.systemGroups.data.columns   = columns;
        $scope.systemGroups.active_item    = {};
        $scope.working = false;

        nutupane.setColumns();

        nutupane.get();

        $scope.addSystemsToGroups = function() {
            $scope.working = true;
            var getIdFromRow = function(row) {
                return row.row_id;
            };
            var systemIds = $.map($scope.table.get_selected_rows(), getIdFromRow);
            var systemGroupIds = $.map($scope.systemGroups.get_selected_rows(), getIdFromRow);
            var data = {group_ids: systemGroupIds, ids:systemIds};

            $http.post(KT.routes.bulk_add_system_group_systems_path(), data).then(function(response) {
                $scope.working = false;
                // Work around AngularJS not providing direct access to the XHR object
                response.getResponseHeader = response.headers;
                notices.checkNoticesInResponse(response);
            });
        };
    }]
);
