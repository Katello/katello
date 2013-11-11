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

describe('Directive: alchMenu', function() {
    var scope,
        compile,
        window,
        testMenu,
        element,
        elementScope;

    beforeEach(module(
        'alchemy',
        'incubator/views/alch-menu.html',
        'incubator/views/alch-dropdown.html',
        'incubator/views/alch-flyout.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_, $window) {
        compile = _$compile_;
        scope = _$rootScope_;
        window = angular.element($window);
    }));

    beforeEach(function() {
        testMenu = {items: [
            {url: 'http://redhat.com', display: 'Red Hat'},
            {url: 'http://google.com', display: 'Google'},
            {display: 'Projects', type: 'dropdown', items: [
                {url: 'http://katello.org', display: 'Katello'},
                {url: 'http://theforeman.org', display: 'Foreman'}
            ]}
        ]};
        scope.items = testMenu;

        element = angular.element('<nav alch-menu="items"></nav>');
        compile(element)(scope);
        scope.$digest();

        elementScope = element.isolateScope();
    });

    it("should display a nav", function() {
        expect(element.is('nav')).toBe(true);
    });

    it("should display a .menu-container <ul>", function() {
        expect(element.find('.menu-container').length).toBe(1);
    });

    it("should display a .menu-item <li> for each top level menu item", function() {
        expect(element.find('.menu-item').length).toBe(3);
    });

    it("should display an <li> element for each item (including children).", function() {
        expect(element.find('li').length).toBe(5);
    });

    describe("should handle mouse events for child dropdowns", function() {
        var target;

        beforeEach(function() {
            target = angular.element(element.find('li')[2]);
            spyOn(elementScope, 'handleHover').andCallThrough();
        });

        it("by setting the item to active on mouse in", function() {
            target.mouseenter();

            expect(elementScope.handleHover).toHaveBeenCalledWith(testMenu.items[2], true);
            expect(testMenu.items[2].active).toBe(true);
            expect(elementScope.dropdown.show).toBe(true);
            expect(elementScope.dropdown).toBe(testMenu.items[2].items);
        });

        it("by setting the item to inactive on mouse out", function() {
            target.mouseenter();
            target.mouseleave();

            expect(elementScope.handleHover).toHaveBeenCalledWith(testMenu.items[2], false);
            expect(elementScope.dropdown.show).toBe(false);
        });
    });
});
