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
 * @ngdoc factory
 * @name  Katello.factory:Nutupane
 *
 * @requires $location
 * @requires $http
 * @requires current_organization
 *
 * @description
 *   Defines the Nutupane factory for adding common functionality to the Nutupane master-detail
 *   pattern.
 *
 * @example - Within a controller, the following needs to be set
 *   $scope.table                = Nutupane.table;
 *   $scope.table.url            = KT.routes.api_systems_path();
 *   $scope.table.transform      = transform;
 *   $scope.table.model          = 'Systems';
 *   $scope.table.data.columns   = columns;
 *   $scope.table.active_item    = {};
 *
 *   Nutupane.setColumns();
 *
 *   Nutupane.default_item_url = function(id) {
 *       return KT.routes.edit_system_path(id);
 *   };
 *
 *   Nutupane.get(function() {
 *       if ($location.search().item) {
 *           $scope.table.select_item(undefined, $location.search().item);
 *       }
 *   });
 */
angular.module('Katello').factory('Nutupane', ['$location', '$http', 'current_organization', function($location, $http, current_organization){
    var sort = { by: 'name', order: 'ASC' },
        Nutupane = {
            table : {
                offset: 0,
                visible: true,
                detailsVisible: false,
                total: 0,
                searchString: $location.search().search,
                loading_more: false,
                items: []
            },
            sort : sort
        },
        allColumns, shownColums;

    Nutupane.get = function(callback) {
        Nutupane.table.working = true;

        return $http.get(Nutupane.table.url, {
            params : {
                'organization_id':  current_organization,
                'search':           $location.search().search,
                'sort_by':          sort.by,
                'sort_order':       sort.order,
                'paged':            true,
                'offset':           Nutupane.table.offset,
                'page_size':        25,
                'expanded':         true
            }
        })
        .then(function(response){
            var table = Nutupane.table,
                data = response.data;

            if( !table.loading_more ){
                table.items     = data.records;
                table.offset    = data.records.length;
                table.total     = data.total;
                table.subtotal  = data.subtotal;
            } else {
                table.offset += data.records.length;
                table.items  = table.items.concat(data.records);
            }

            if ($location.search().search) {
                table.searchTerm = $location.search().search;
            }

            if (callback) {
                callback(data);
            }

            table.working = false;
        });
    };

    Nutupane.table.search = function(searchTerm) {
        $location.search('search', searchTerm);
        Nutupane.table.offset = 0;
        Nutupane.table.close_item();
        Nutupane.table.loading_more = false;

        Nutupane.get();
    };

    Nutupane.table.nextPage = function(){
        var table = Nutupane.table;

        if (table.loading_more || table.working || table.subtotal === table.offset) {
            return;
        }

        table.loading_more = true;

        Nutupane.get(function(){
            table.loading_more = false;
        });
    };

    Nutupane.table.sort = function(column) {
        if (column.id === sort.by) {
            sort.order = (sort.order === 'ASC') ? 'DESC' : 'ASC';
        } else {
            sort.order = 'ASC';
            sort.by = column.id;
        }

        angular.forEach(Nutupane.table.data.columns, function(column) {
            if (column.active) {
                column.active = false;
            }
        });

        column.active = true;

        Nutupane.table.offset = 0;
        Nutupane.get(function(){
            angular.forEach(Nutupane.table.data.columns, function(column){
                if (column.active) {
                    column.active = false;
                }
            });

            column.active = true;
        });
    };

    /**
     * Set the visibility of the details pane.
     * @param visibility boolean
     */
    Nutupane.table.setDetailsVisibility = function(visibility) {
        var table = Nutupane.table;

        if (visibility) {
            // Remove all columns except name and replace them with the details pane
            //table.data.columns = shownColums;
        } else {
            // Restore the former columns
            //table.data.columns = allColumns;
        }

        table.detailsVisible = visibility;
    };

    /**
     * Set the visibility of the new item pane.
     * @param visibility boolean
     */
    Nutupane.table.setNewItemVisibility = function(visibility) {
        if (visibility) {
            $('body').addClass('no-scroll');
        } else {
            $('body').removeClass('no-scroll');
        }
        Nutupane.table.newPaneVisible = visibility;
    };

    Nutupane.table.close_item = function () {
        Nutupane.table.setDetailsVisibility(false);
        // Restore the former columns
        Nutupane.table.columns = allColumns;
        $location.search('item', '');
    };

    Nutupane.selectItem = function(url, id){
        var item,
            table = Nutupane.table;

        $location.search('item', id.toString());
        url = url ? url : Nutupane.default_item_url(id);

        $http.get(url, {
            params : {
                expanded : true
            }
        })
        .then(function(response){
            table.visible = false;

            // Only reset the active_item if an ID is provided
            if (id) {
                // Remove all columns except name and replace them with the details pane
                //table.data.columns = shownColums;
                table.selectAll(false);
                //table.active_item = item;
                //table.active_item.selected  = true;
                //rowSelect = false;
            }

            table.active_item.html = response.data;
            Nutupane.table.setDetailsVisibility(true);
        });
    };

    return Nutupane;

}]);

/**
 * @ngdoc directive
 * @name  Katello.directive:nutupaneDetails
 *
 * @scope
 *
 * @element ANY
 *
 * @description
 *   Turns an element into a container for holding detail pages fetched by Nutupane. By setting
 *   the html property on the bound model, the payload wll be inserted as the html into the
 *   element as inner html. Connects up a close button to remove the element form view and allows
 *   sub-menu items to call out to the select_item() functionality of Nutupane. This is currently
 *   tied to the legacy tupane details page fetching.
 *
 * @example
 *   <span class="nutupane-details panel" id="nutupane-details" nutupane-details="table.visible" model="table" ng-class="{ 'nutupane-details-open' : !model.visible }">
 */
angular.module('Katello').directive('nutupaneDetails', [function(){
    return {
        replace: false,
        scope: {
            'model': '='
        },
        link: function(scope, elem, attrs) {
            scope.$watch('model.active_item.html', function(item){
                elem.html(item);

                var children = angular.element(elem).find('.menu_parent');
                angular.forEach(children, function(item, index) {
                    KT.menu.hoverMenu(item, { top : '75px' });
                });

                elem.find('.panel_link > a').on('click', function() {
                    var element = this;

                    scope.$apply(function() {
                        scope.model.select_item(angular.element(element).attr('href'));
                    });
                });
            });

            elem.find('.close').on('click', function() {
                scope.$apply(function() {
                    scope.model.close_item();
                });
            });

        }
    };
}]);
