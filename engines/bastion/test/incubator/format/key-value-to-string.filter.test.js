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
describe('Filter:keyValueToString', function() {
    var keyValues, keyValueFilter;

    beforeEach(module('alchemy.format'));

    beforeEach(inject(function($filter) {
        keyValues = [
            {keyname: 'keyOne', value: 'valueOne'},
            {keyname: 'keyTwo', value: 'valueTwo'},
            {keyname: 'keyThree', value: 'valueThree'},
        ];
        keyValueFilter = $filter('keyValueToString');
    }));

    it("transforms an array of key, values to a string.", function() {
        expect(keyValueFilter(keyValues)).
            toBe('keyOne: valueOne, keyTwo: valueTwo, keyThree: valueThree');
    });

    it("ensures transform value is an array before proceeding", function() {
        expect(keyValueFilter({keyname: 'key', value: 'value'})).toBe('key: value');
    });

    describe("allows overriding default defaults.", function() {
        var options;
        beforeEach(function() {
            options = {};
        });

        it("by providing a custom separator", function() {
            options.separator = '='
            expect(keyValueFilter(keyValues, options)).
                toBe('keyOne=valueOne, keyTwo=valueTwo, keyThree=valueThree');
        });

        it('by providing a custom key name', function() {
            options.keyName = 'key';
            expect(keyValueFilter({key: 'key', value: 'value'}, options)).
                toBe('key: value');
        });

        it('by providing a custom value name', function() {
            options.valueName = 'valueeee';
            expect(keyValueFilter({keyname: 'key', valueeee: 'value'}, options)).
                toBe('key: value');
        });
    });
});
