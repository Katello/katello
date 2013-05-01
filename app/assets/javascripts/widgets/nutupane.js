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

angular.module('Katello').factory('Nutupane', ['$location', '$http', 'current_organization', function($location, $http, current_organization){
    var sort = { by: 'name', order: 'ASC' },
        Nutupane = {
            table : {
                data    : {},
                offset  : 0,
                visible : true,
                total   : 0,
                search_string : $location.search().search,
                loading_more : false
            },
            sort : sort
        };

    Nutupane.get = function(callback){
        Nutupane.table.working = true;

        return $http.get(Nutupane.table.url, {
            params : {
                'organization_id':  current_organization,
                'search':           $location.search().search,
                'sort_by':          sort.by,
                'sort_order':       sort.order,
                'paged':            true,
                'offset':           Nutupane.table.offset
            }
        })
        .then(function(response){
            var table = Nutupane.table,
                data = table.transform(response.data);

            if( !table.loading_more ){
                table.offset    = data.rows.length;
                table.data.rows = data.rows;
                table.total     = data.total;
                table.subtotal  = data.subtotal;
            } else {
                table.offset += data.rows.length;
                table.data.rows = table.data.rows.concat(data.rows);
            }

            if ( callback ){
                callback();
            }

            table.working = false;
        });
    };

    Nutupane.table.search = function(search_term){
        $location.search('search', search_term);
        Nutupane.table.offset = 0;

        Nutupane.get();
    };

    Nutupane.table.next_page = function(){
        var table = Nutupane.table;

        if (table.loading_more || table.working || table.subtotal === table.offset) {
            return;
        }

        table.loading_more = true;

        Nutupane.get(function(){
            table.loading_more = false;
        });
    };

    Nutupane.table.sort = function(column){
        if (column.id === sort.by){
            sort.order = (sort.order === 'ASC') ? 'DESC' : 'ASC';
        } else {
            sort.order = 'ASC';
            sort.by = column.id;
        }

        angular.forEach(Nutupane.table.data.columns, function(column){
            if( column.active ){
                column.active = false;
            }
        });

        column.active = true;

        Nutupane.get(function(){
            angular.forEach(Nutupane.table.data.columns, function(column){
                if( column.active ){
                    column.active = false;
                }
            });

            column.active = true;
        });
    };

    return Nutupane;
}]);

angular.module('Katello').directive('nutupaneDetails', [function(){
    return {
        replace: false,
        scope: {
            'model': '='
        },
        link: function(scope, elem, attrs) {
            scope.$watch('model.active_item', function(item){
                elem.html(item);
            });

            elem.find('.close').live('click', function() {
                scope.$apply(function() {
                    scope.model.close_item();
                });
            });

            elem.find('.panel_link').live('click', function() {
                scope.model.select_item(angular.element(this).find('a').attr('href'));
            });
        }
    };
}]);
