/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/


angular.module('Katello').controller('SystemsController',
    ['$scope', 'Nutupane', '$location', '$http', '$compile',
    function($scope, Nutupane, $location, $http, $compile) {

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
                            display: system.created_at,
                            column_id: 'created_at'
                        },{
                            display: system.updated_at,
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

        var allColumns = $scope.table.data.columns.slice(0);
        var nameColumn = $scope.table.data.columns.slice(0).splice(0, 1);

        /**
         * Set the visibility of the details pane.
         * @param visibility boolean
         */
        var setDetailsVisibility = function (visibility) {
            if (visibility) {
                // Remove all columns except name and replace them with the details pane
                $scope.table.data.columns = nameColumn;
            } else {
                // Restore the former columns
                $scope.table.data.columns = allColumns;
                $location.search("");
            }
            $scope.table.detailsVisible = visibility;
        }

        /**
         * Set the visibility of the new systems pane.
         * @param visibility boolean
         */
        var setNewSystemVisibility = function (visibility) {
            $scope.newPaneVisible = visibility;
        }

        $scope.createNewSystem = function () {
            var createSuccess = function (data) {
                $scope.$apply(function () {
                    setNewSystemVisibility(false);
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
                setDetailsVisibility(false);
                setNewSystemVisibility(true);

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

        $scope.table.select_item = function(url, id) {
            var system;

            if (id) {
                angular.forEach($scope.table.data.rows, function(row) {
                    if (row.row_id.toString() === id.toString()) {
                        system = row;
                    }
                });
            }
            url = url ? url : KT.routes.edit_system_path(id);

            $http.get(url, {
                params : {
                    expanded : true
                }
            })
            .then(function(response){
                $scope.table.visible = false;

                // Only reset the active_item if an ID is provided
                if (id) {
                    $location.search('item', id);
                    $scope.table.select_all(false);
                    $scope.table.active_item = system;
                    $scope.table.active_item.selected = true;
                    $scope.rowSelect = false;
                }
                $scope.table.active_item.html = response.data;
                setDetailsVisibility(true);
            });
        };

        $scope.table.close_item = function () {
            setDetailsVisibility(false);
        };

        if( $location.search().item ){
            $scope.select_item($location.search().item);
        }

        Nutupane.get();
    }]
);
