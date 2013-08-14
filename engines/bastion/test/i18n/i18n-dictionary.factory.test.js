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
describe('Factory:i18nDictionary', function() {
    // Mocks
    var $resource, $cacheFactory, cache, i18nDictionary, Routes;

    // Load the i18n module
    beforeEach(module('Bastion.i18n'));

    // Set up the mocks
    beforeEach(module(function($provide) {
        Routes = {
            i18nDictionaryPath: function() {
                return "i18n/dictionary.json";
            }
        };

        $resource = function() {
            this.get = function() {
                return {sandwich: "torta"};
            };
            return this;
        };

        $provide.value('$resource', $resource);
        $provide.value('Routes', Routes);
    }));

    beforeEach(inject(function(_$cacheFactory_, _i18nDictionary_) {
        $cacheFactory = _$cacheFactory_;
        i18nDictionary = _i18nDictionary_;
        cache = $cacheFactory.get("i18n");
    }));

    it("retrieves the translation file.", function() {
        var response = i18nDictionary.get();
        expect(response.sandwich).toBe("torta");
    });

    describe('maintains a cache of requests.', function() {

        it("returns the result in the cache if it exists.", function() {
            spyOn(cache, "get").andReturn("something");
            expect(i18nDictionary.get()).toBe("something");
        });

        it("does not add the result to the cache if it exists.", function() {
            spyOn(cache, "get").andReturn("something");
            spyOn(cache, "put");
            i18nDictionary.get();
            expect(cache.get).toHaveBeenCalled();
            expect(cache.put).not.toHaveBeenCalled();

        });

        it("adds the result to the cache if it doesn't exist.", function() {
            spyOn(cache, "get").andReturn(null);
            spyOn(cache, "put");
            i18nDictionary.get();
            expect(cache.get).toHaveBeenCalled();
            expect(cache.put).toHaveBeenCalled();
        });
    });
});
