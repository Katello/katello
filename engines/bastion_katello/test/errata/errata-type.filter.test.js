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
 */
describe('Filter:errataType', function() {
    var filter;

    beforeEach(module('Bastion.errata'));

    beforeEach(module(function($provide) {
        $provide.value('translate',  function(a) {return a});
    }));

    beforeEach(inject(function($filter) {
        filter = $filter('errataType');
    }));

    it("returns 'Bug Fix Advisory' if bugfix.", function() {
        expect(filter('bugfix')).toBe('Bug Fix Advisory');
    });

    it("returns 'Product Enhancement Advisory' if enhancement.", function() {
        expect(filter('enhancement')).toBe('Product Enhancement Advisory');
    });

    it("returns 'Secuirty Advisory' if security.", function() {
        expect(filter('security')).toBe('Security Advisory');
    });

    it("returns provided type if not found.", function() {
        expect(filter('blah')).toBe('blah');
    });
});
