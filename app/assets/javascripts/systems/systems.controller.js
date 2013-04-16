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

angular.module('Katello').factory('SystemTable', ['Nutupane', function(Nutupane){
    var SystemTable = {};

    SystemTable.get = function(sort, offset, callback){
        Nutupane.get({
            url:        '/katello/api/systems/',
            sort:       sort,
            callback:   callback,
            offset:     offset,
            transform:  SystemTable.transform
        });
    };

    SystemTable.transform = function(data){
        var table_data = {};

        table_data.rows = [];
        angular.forEach(data.systems,
            function(system){
                var row = {
                    'row_id' : system.id,
                    'show'  : true,
                    'cells': [{ 
                        display: system.name,
                        column_id: 'name'
                    },{ 
                        display: system.environment.name,
                        column_id: 'environment'
                    },{ 
                        display: system.content_view_id ? system.content_view_id : "",
                        column_id: 'content_view_id'
                    }]
                };
                table_data.rows.push(row);
            });

        return {
            data    : table_data,
            total   : data.total,
            subtotal: data.subtotal
        };
    };

    return SystemTable;

}]);

angular.module('Katello').controller('SystemsController', ['$scope', 'SystemTable', '$location', function($scope, SystemTable, $location){
    var sort = { by: 'name', order: 'ASC' };

    $scope.table        = {};
    $scope.table.data   = {};
    $scope.table.start  = 0;
    $scope.table.offset = 0;
    $scope.table.total  = 0;
    $scope.table.model  = 'Systems';
    $scope.table.search_string = $location.search().search;

    $scope.table.data.columns = [{
        id: 'name',
        display: 'Name', 
        show: true
    },{
        id: 'environment',
        display: 'Environment',
        show: true
    },{
        id: 'content_view_id',
        display: 'Content View',
        show: true
    }];

    var fetch = function(callback){
        $scope.table.working = true;

        SystemTable.get(sort, $scope.table.start, function(data){

            if( !$scope.table.loading_more ){
                $scope.table.start      = data.data.rows.length;
                $scope.table.data.rows  = data.data.rows;
                $scope.table.total      = data.total;
                $scope.table.offset     = data.subtotal;
            } else {
                $scope.table.start += data.data.rows.length;
                $scope.table.data.rows = $scope.table.data.rows.concat(data.data.rows);
            }

            if ( callback ){ 
                callback();
            }

            $scope.table.working = false;
        });
    };

    $scope.table.sort = function(column){
        if (column.id === sort.by){
            sort.order = (sort.order === 'ASC') ? 'DESC' : 'ASC';
        } else {
            sort.order = 'ASC';
            sort.by = column.id;
        }

        angular.forEach($scope.table.data.columns, function(column){
            if( column.active ){
                column.active = false;
            }
        });

        column.active = true;

        fetch(function(){
            angular.forEach($scope.table.data.columns, function(column){
                if( column.active ){
                    column.active = false;
                }
            });

            column.active = true;
        });
    };

    $scope.table.search = function(search_term){
        $location.search('search', search_term);

        fetch();
    };

    $scope.table.next_page = function(){
        if ($scope.table.loading_more || $scope.table.start === $scope.table.offset) { 
            return;
        }

        $scope.table.loading_more = true;

        fetch(function(){
            $scope.table.loading_more = false;
        });
    };

    fetch();

}]);
