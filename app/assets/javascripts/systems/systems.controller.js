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
    ['$scope', 'Nutupane', '$location', 'System', '$compile',
    function($scope, Nutupane, $location, System, $compile) {

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

        var transform = function(data){
            var rows = [];

            angular.forEach(data.systems,
                function(system){
                    var row = {
                        'row_id' : system.id,
                        'show'  : true,
                        'cells': [{
                            display: $compile('<a ng-click="select_item(\'' + system.uuid + '\')">' + system.name + '</a>')($scope),
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

        var allColumns = $scope.table.data.columns.slice(0);
        var nameColumn = $scope.table.data.columns.slice(0).splice(0, 1);

        $scope.select_item = function(id){
            $location.search('item', id);
            System.get({systemId: id, expanded : true}, function (system) {
                $scope.table.visible = false;
                $scope.system = system;
                // Remove all columns except name and replace them with the details pane
                $scope.table.data.columns = nameColumn;
            });
        };

        $scope.close_item = function () {
            $location.search("");
            $scope.table.visible = true;
            // Restore the former columns
            $scope.table.data.columns = allColumns;
        };

        if( $location.search().item ){
            $scope.select_item($location.search().item);
        }

        Nutupane.get();
    }]
);
