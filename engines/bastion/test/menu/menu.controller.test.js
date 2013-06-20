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
describe('Controller:MenuController', function() {
    // Mocks
    var $location, $scope, menus;

    var orgSwitcherElement;

    // load the widgets module
    beforeEach(module('Bastion.menu'));

    // Set up the mocks
    beforeEach(function() {
        // Mock out menus menu related functionality
        menus = {
            menu: {
                items: [
                    {
                        key: 'main1',
                        url: "/main1",
                        items: [
                            {
                                key: "main1a",
                                url: "/main1a"
                            },
                            {
                                key: "main2a",
                                url: "/main2a"
                            },
                        ]
                    },
                    {
                        key: 'main2',
                        url: "/main2"
                    }
                ]
            },
            userMenu: {items: []},
            adminMenu: {items: []},
            notices: []
        };

        $location = {
            absUrl: function() {
                return '/main2';
            }
        };
    });

    // Initialize controller
    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        $controller('MenuController', {$scope: $scope, $location: $location, Menus: menus});
    }));

    describe("gets the active menu item", function() {
        it("if the menu item is the root element returns root element", function() {
            expect($scope.menu.activeItem.key).toBe("main2");
        });

        it("if the menu item is a child element returns it's root element", function() {
            $location = {
                absUrl: function() {
                    return '/main1a';
                }
            };
            inject(function($controller, $rootScope) {
                $scope = $rootScope.$new();
                $controller('MenuController', {$scope: $scope, $location: $location, Menus: menus});
            });
            expect($scope.menu.activeItem.key).toBe("main1");
        });
    });

    it("allows setting of the active menu item.", function() {
        $scope.setActiveMenuItem({key: "blah", active: false});
        expect($scope.menu.activeItem.key).toBe("blah");
        expect($scope.adminMenu.activeItem.key).toBe("blah");
        expect($scope.menu.activeItem.active).toBe(true);
        expect($scope.adminMenu.activeItem.active).toBe(true);
    });
});

