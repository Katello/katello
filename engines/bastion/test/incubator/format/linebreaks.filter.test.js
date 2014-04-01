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
describe('Filter:linebreaks', function() {
    var stringWithNewLines, linebreaksFilter;

    beforeEach(module('alchemy.format'));

    beforeEach(inject(function($filter) {
        stringWithNewLines = "I have\n more than one\n line!";
        linebreaksFilter = $filter('linebreaks');
    }));

    it("transforms a string with newlines to a string with <br/>s.", function() {
        expect(linebreaksFilter(stringWithNewLines)).toBe('I have<br/> more than one<br/> line!');
    });

    it("returns the provided input if the input is not a string", function() {
        expect(linebreaksFilter(1)).toBe(1);
    });
});
