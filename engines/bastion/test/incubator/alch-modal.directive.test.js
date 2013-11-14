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

describe('Directive: alchModal', function() {
    var scope,
        compile,
        $modal,
        $q,
        translate,
        testItem,
        element,
        elementScope;

    beforeEach(module('alchemy', 'incubator/views/alch-modal-remove.html'));

    beforeEach(module(function($provide) {
        testItem = {
            name: 'Test Name',
            taco: 'carnitas',
            delete: function() {}
        };

        translate = function() {
            this.$get = function() {
                return function() {};
            };
        };

        $modal = {
            $get: function() {
                return this;
            },
            open: function() {
                var deferred = $q.defer();
                deferred.resolve({});

                return {
                    result: deferred.promise
                }
            }
        };

        $provide.provider('translateFilter', translate);
        $provide.provider('$modal', $modal);
    }));

    beforeEach(inject(function(_$compile_, _$rootScope_, _$q_) {
        compile = _$compile_;
        scope = _$rootScope_;
        $q = _$q_;
    }));

    beforeEach(function() {
        element = angular.element(
            '<span alch-modal="item.delete(item)" model="testItem">' +
                '<p>Hello!</p></span>');

        compile(element)(scope);
        scope.$digest();

        elementScope = element.scope();
    });

    it("allows the opening of a modal dialog via bootstrap ui", function() {
        spyOn($modal, 'open').andCallThrough();

        elementScope.openModal();

        expect($modal.open).toHaveBeenCalled();
    });
});
