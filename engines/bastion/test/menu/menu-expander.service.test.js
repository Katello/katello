/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

describe('Service: MenuExpander', function() {
    var menuExpander;

    beforeEach(module('Bastion.menu'));

    beforeEach(inject(function(MenuExpander) {
        menuExpander = MenuExpander;
    }));

    describe('sets menu items', function() {
        it('by adding a menu if the menu does not exist', function() {
            var menu = [{'url': 'http://google.com', 'label': 'google'}];

            menuExpander.setMenu('system', menu);

            expect(menuExpander.getMenu('system')).toBe(menu);
        });

        it('by adding to the menu if it already exists', function() {
            var menu1 = [{'url': 'http://google.com', 'label': 'google'}],
                menu2 = [{'url': 'http://redhat.com', 'label': 'redhat'}];

            menuExpander.setMenu('system', menu1);
            menuExpander.setMenu('system', menu2);

            expect(menuExpander.getMenu('system').length).toBe(2);
            expect(menuExpander.getMenu('system')[0]).toBe(menu1[0]);
            expect(menuExpander.getMenu('system')[1]).toBe(menu2[0]);
        });

        it('by not adding duplicate menu items', function() {
            var menu1 = [{'url': 'http://google.com', 'label': 'google'}],
                menu2 = [{'url': 'http://google.com', 'label': 'google'}];

            menuExpander.setMenu('system', menu1);
            menuExpander.setMenu('system', menu2);

            expect(menuExpander.getMenu('system').length).toBe(1);
            expect(menuExpander.getMenu('system')[0]).toBe(menu1[0]);
        });
    });

    describe("gets menu items", function() {
        it('by returning an empty array if the menu does not exist.', function() {
            expect($.isArray(menuExpander.getMenu('system'))).toBe(true);
            expect(menuExpander.getMenu('system').length).toBe(0);
        });

        it('by returning the menu if it exists.', function() {
            var menu = [{'url': 'http://google.com', 'label': 'google'}];

            expect(menuExpander.getMenu('system').length).toBe(0);

            menuExpander.setMenu('system', menu);

            expect(menuExpander.getMenu('system').length).toBe(1);
            expect(menuExpander.getMenu('system')).toBe(menu);
        });
    });
});

