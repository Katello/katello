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
 **/

(function() {
    'use strict';

    /**
     * @ngdoc object
     * @name Bastion.menu.controller:MenuController
     *
     * @requires $scope
     * @requires $location
     * @requires Menus
     *
     * @description
     * A controller for all menu related functionality.
     */
    angular.module('Bastion.menu').controller('MenuController', ['$scope', '$location', 'Menus', function($scope, $location, Menus) {
        $scope.menu       = Menus.menu;
        $scope.userMenu  = Menus.userMenu;
        $scope.adminMenu = Menus.adminMenu;
        $scope.notices    = Menus.notices;

        /**
         * Set the active menu item.
         * @param menuItem the menuItem to make active.
         */
        $scope.setActiveMenuItem = function(menuItem) {
            if (menuItem) {
                $scope.menu.activeItem = menuItem;
                $scope.adminMenu.activeItem = menuItem;
                $scope.menu.activeItem.active = true;
                $scope.adminMenu.activeItem.active = true;
            }
        };

        /**
         * Get the active menu item based on the $location service.
         * @param menuItems
         * @returns the active menu item.
         */
        $scope.getActiveMenuItem = function(menuItems) {
            var activeMenuItem;
            for (var i = 0; i < menuItems.length; i += 1) {
                var menuItem = menuItems[i];
                if ($location.absUrl().indexOf(menuItem.url) >= 0) {
                    activeMenuItem = menuItem;
                } else if (menuItem.hasOwnProperty('items')) {
                    // If the active page is a child of a top level menu item
                    // then set the top level menu item as active.
                    if ($scope.getActiveMenuItem(menuItem.items)) {
                        activeMenuItem = menuItem;
                    }
                }
            }
            return activeMenuItem;
        };

        // Combine all menu items and figure out which one ought to be active.
        var allMenus = $scope.menu.items.concat($scope.userMenu.items).
            concat($scope.adminMenu.items).concat($scope.notices);
        $scope.setActiveMenuItem($scope.getActiveMenuItem(allMenus));
    }]);
})();
