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

'use strict';

Katello.controller('MenuController', ['$scope', '$location', '$document', function($scope, $location, $document){

    $scope.menu = KT.main_menu;
    $scope.user_menu = KT.user_menu;
    $scope.admin_menu = KT.admin_menu;
    $scope.notices = KT.notices;

    /**
     * Set the active menu item.
     * @param menuItem the menuItem to make active.
     */
    function setActiveMenuItem (menuItem) {
        if (menuItem) {
            $scope.menu.active_item = menuItem;
            $scope.menu.active_item.active = true;
        }
    }

    /**
     * Get the active menu item based on the $location service.
     * @param menuItems
     * @returns the active menu item.
     */
    function getActiveMenuItem (menuItems) {
        var activeMenuItem;
        for (var i = 0; i < menuItems.length; i++) {
            var menuItem = menuItems[i];
            if ($location.absUrl().indexOf(menuItem.url) >= 0) {
                activeMenuItem = menuItem;
            } else if (menuItem.hasOwnProperty('items')) {
                // If the active page is a child of a top level menu item
                // then set the top level menu item as active.
                if (getActiveMenuItem(menuItem.items)) {
                    activeMenuItem = menuItem;
                }
            }
        }
        return activeMenuItem;
    }

    // Hide the org switcher menu if the user clicks outside of it
    var orgSwitcherMenuLink = angular.element('#orgSwitcherNav a.organization-name');
    $document.bind('click', function (event) {
        var target = angular.element(event.target);
        if (target[0] !== orgSwitcherMenuLink[0]) {
            $scope.showMenu = false;
            $scope.$apply();
        }
    });

    // Combine all menu items and figure out which one ought to be active.
    var allMenus = $scope.menu.items.concat($scope.user_menu.items).
        concat($scope.admin_menu.items).concat($scope.notices);
    setActiveMenuItem(getActiveMenuItem(allMenus));
}]);
