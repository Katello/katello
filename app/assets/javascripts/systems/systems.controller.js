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
 *
 * @description
 *   Provides the functionality specific to Systems for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Katello').controller('SystemsController',
    ['$scope', 'Nutupane', '$location', '$compile', '$filter', '$http',
    function($scope, Nutupane, $location, $compile, $filter, $http) {

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
            id: 'content_view_id',
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
                            display: $compile('<a ng-click="table.select_item(\'' + KT.routes.edit_system_path(system.id) + '\',' + system.id + ')">' + system.name + '</a>')($scope),
                            column_id: 'name'
                        },{
                            display: system.description,
                            column_id: 'description'
                        },{
                            display: system.environment.name,
                            column_id: 'environment'
                        },{
                            display: system.content_view_id ? system.content_view_id : "",
                            column_id: 'content_view_id'
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

        $scope.table                = Nutupane.table;
        $scope.table.url            = KT.routes.api_systems_path();
        $scope.table.transform      = transform;
        $scope.table.model          = 'Systems';
        $scope.table.data.columns   = columns;
        $scope.table.active_item    = {};

        Nutupane.set_columns();

        $scope.createNewSystem = function () {
            var createSuccess = function (data) {
                $scope.$apply(function () {
                    Nutupane.setNewSystemVisibility(false);
                    $scope.table.select_item(KT.routes.edit_system_path(data.system.id));
                });
                notices.checkNotices();
            };

            // Temporarily get the old new systems UI
            // TODO REPLACE ME
            $http.get(KT.routes.new_system_path()).then(function (response) {
                var content = $('#nutupane-new-item .nutupane-pane-content'),
                    data = KT.common.getSearchParams() || {},
                    button = content.find('input[type|="submit"]');

                content.html(response.data);
                Nutupane.setDetailsVisibility(false);
                Nutupane.setNewSystemVisibility(true);

                content.find('#new_system').submit(function (event) {
                    event.preventDefault();
                    $(this).ajaxSubmit({
                        url: KT.routes.systems_path(),
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

        Nutupane.default_item_url = function(id) {
            return KT.routes.edit_system_path(id);
        };

        Nutupane.get(function() {
            if ($location.search().item) {
                $scope.table.select_item(undefined, $location.search().item);
            }
        });
    }]
);
