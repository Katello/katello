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
describe('Filter:i18n', function() {
    var i18n, i18nFilter, i18nDictionary;

    // load the i18n module and i18nDictionary constant.
    beforeEach(module('Katello.i18n'));

    // Set up mocks
    beforeEach(module(function($provide) {
        i18nDictionary = {
            sandwich: "torta",
            taco: "taco",
            eat: function(x,y) {
                return "Me gusta comer %x y %y.".replace('%x', x).replace('%y', y);
            }
        };
        $provide.value('i18nDictionary', i18nDictionary);
    }));

    // Create i18n filter
    beforeEach(inject(function($filter) {
        i18nFilter = $filter('i18n');
    }));

    describe("Looks up a translation in the i18n dictionary", function() {
        it("returns the translation if it exists.", function() {
            expect(i18nFilter('sandwich')).toBe("torta");
            expect(i18nFilter('taco')).toBe("taco");
        });

        it("returns the key if the translation does not exist.", function() {
            expect(i18nFilter('pierogi')).toBe('pierogi');
        });
    });

    describe("Allows for replacement strings in translations.", function() {
        it("substitues the provided replacement strings.", function() {
           expect(i18nFilter('eat', ['burritos', 'enchiladas'])).toBe("Me gusta comer burritos y enchiladas.");
        });

        it("ignores extra replacement strings.", function() {
            expect(i18nFilter('eat', ['burritos', 'enchiladas', 'carnitas'])).toBe("Me gusta comer burritos y enchiladas.");
        });
    });
});
