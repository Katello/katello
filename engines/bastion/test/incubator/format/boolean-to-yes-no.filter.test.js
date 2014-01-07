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
describe('Filter:booleanToYesNo', function() {
    var filter;

    beforeEach(module('alchemy.format'));

    beforeEach(module(function($provide) {
        $provide.value('gettext',  function(a) {return a});
    }));

    beforeEach(inject(function($filter) {
        filter = $filter('booleanToYesNo');
    }));

    it("returns 'Yes' for true, and 'No' for false", function() {
        expect(filter(true)).toBe('Yes');
        expect(filter(false)).toBe('No');
    });

    it("returns an empty string for null", function() {
        expect(filter()).toBe('');
        expect(filter('')).toBe('');
    });

    it("allows Yes and No to be overriden", function() {
        expect(filter(true, 'ok', 'fail')).toBe('ok');
        expect(filter(false, 'ok', 'fail')).toBe('fail');
    });

});
