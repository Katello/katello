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
describe('Filter:errataSeverity', function() {
    var filter;

    beforeEach(module('Bastion.errata'));

    beforeEach(module(function($provide) {
        $provide.value('translate',  function(a) {return a});
    }));

    beforeEach(inject(function($filter) {
        filter = $filter('errataSeverity');
    }));

    it("returns 'Moderate' if moderate.", function() {
        expect(filter('Moderate')).toBe('Moderate');
    });

    it("returns 'Important' if important.", function() {
        expect(filter('Important')).toBe('Important');
    });

    it("returns 'Critical' if critical.", function() {
        expect(filter('Critical')).toBe('Critical');
    });

    it("returns 'N/A' if ''.", function() {
        expect(filter('')).toBe('N/A');
    });

    it("returns provided type if not found.", function() {
        expect(filter('blah')).toBe('blah');
    });
});
