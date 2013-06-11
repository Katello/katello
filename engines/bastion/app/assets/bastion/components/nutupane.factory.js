/*global KT*/
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
 * @requires CurrentOrganization
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
 *   $scope.table.activeItem    = {};
 *
 *   Nutupane.setColumns();
 *
 *   Nutupane.defaultItemUrl = function(id) {
 *       return KT.routes.edit_system_path(id);
 *   };
 *
 *   Nutupane.get(function() {
 *       if ($location.search().item) {
 *           $scope.table.selectItem(undefined, $location.search().item);
 *       }
 *   });
 */
angular.module('Katello').factory('Nutupane', ['$location', '$http', 'CurrentOrganization', function($location, $http, CurrentOrganization){
    var sort = { by: 'name', order: 'ASC' };

    var Nutupane = function() {
        var self = this;

        self.sort = sort;
        self.table = {
            items: [],
            offset: 0,
            visible: true,
            collapsed: false,
            detailsVisible: false,
            newPaneVisible: false,
            total: 0,
            searchString: $location.search().search,
            loadingMore: false
        };

        self.get = function(callback) {
            self.table.working = true;

            return $http.get(this.table.url, {
                params : {
                    'organization_id':  CurrentOrganization,
                    'search':           $location.search().search,
                    'sort_by':          sort.by,
                    'sort_order':       sort.order,
                    'paged':            true,
                    'offset':           self.table.offset
                }
            })
            .then(function(response){
                var table = self.table,
                    data  = response.data;

                if( !table.loadingMore ){
                    table.offset    = data.records.length;
                    table.items     = data.records;
                    table.total     = data.total;
                    table.subtotal  = data.subtotal;
                } else {
                    table.offset += data.records.length;
                    table.items = table.items.concat(data.records);
                }

                if (callback) {
                    callback();
                }

                table.working = false;
            });
        };

        self.table.search = function(searchTerm){
            $location.search('search', searchTerm);
            self.table.offset = 0;
            self.table.closeItem();

            self.get();
        };

        self.table.nextPage = function(){
            var table = self.table;

            if (table.loadingMore || table.working || table.subtotal === table.offset) {
                return;
            }

            table.loadingMore = true;

            self.get(function(){
                table.loadingMore = false;
            });
        };

        self.table.sort = function(column) {
            if (column.id === sort.by) {
                sort.order = (sort.order === 'ASC') ? 'DESC' : 'ASC';
            } else {
                sort.order = 'ASC';
                sort.by = column.id;
            }

            column.active = true;

            self.table.offset = 0;
            self.get();
        };

        /**
         * Set the visibility of the details pane.
         * @param visibility boolean
         */
        self.table.setDetailsVisibility = function(visibility) {
            var table = self.table;
            if (visibility) {
                table.openActionPane();
            } else {
                table.closeActionPane();
            }

            table.detailsVisible = visibility;
        };

        /**
         * Set the visibility of the new item pane.
         * @param visibility boolean
         */
        self.table.setNewItemVisibility = function(visibility) {
            if (visibility) {
                $('body').addClass('no-scroll');
            } else {
                $('body').removeClass('no-scroll');
            }
            self.table.newPaneVisible = visibility;
        };

        self.table.closeItem = function() {
            self.table.setDetailsVisibility(false);
            $location.search('item', '');
        };

        /**
         * Open the action pane by removing all but the name column.
         */
        self.table.openActionPane = function() {
            self.table.collapsed = true;
        };

        /**
         * Close the action pane by restoring the table columns.
         */
        self.table.closeActionPane = function() {
            self.table.collapsed = false;
        };

        self.table.selectItem = function(url, id) {
            var item,
                table = self.table;

            $location.search('item', id.toString());
            url = url ? url : self.defaultItemUrl(id);

            $http.get(url, {
                params : {
                    expanded : true
                }
            })
            .then(function(response){
                table.visible = false;

                // Only reset the activeItem if an ID is provided
                if (id) {
                    // Remove all columns except name and replace them with the details pane
                    table.selectAll(false);
                    table.activeItem = item;
                    table.activeItem.selected  = true;
                }
                self.table.activeItem.html = response.data;
                self.table.setDetailsVisibility(true);
            });
        };
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
 *   sub-menu items to call out to the selectItem() functionality of Nutupane. This is currently
 *   tied to the legacy tupane details page fetching.
 *
 * @example
 *   <span class="nutupane-details panel" id="nutupane-details" nutupane-details="table.visible" model="table" ng-class="{ 'nutupane-details-open' : !model.visible }">
 */
angular.module('Katello.widgets').directive('nutupaneDetails', [function(){
    return {
        replace: false,
        scope: {
            'model': '='
        },
        link: function(scope, elem) {
            scope.$watch('model.active_item.html', function(item){
                elem.html(item);

                var children = angular.element(elem).find('.menu_parent');
                angular.forEach(children, function(item) {
                    KT.menu.hoverMenu(item, { top : '75px' });
                });

                elem.find('.panel_link > a').on('click', function() {
                    var element = this;

                    scope.$apply(function() {
                        scope.model.selectItem(angular.element(element).attr('href'));
                    });
                });
            });

            elem.find('.close').on('click', function() {
                scope.$apply(function() {
                    scope.model.closeItem();
                });
            });

        }
    };
}]);
