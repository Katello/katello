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


describe('Directive: alchConfirm', function() {
    var scope,
        compile,
        testItem,
        editableElement,
        elementScope;

    beforeEach(module('alchemy', 'incubator/views/alch-confirm.html'));

    beforeEach(module(function($provide) {
        testItem = {
            name: 'Test Name',
            taco: 'carnitas',
            delete: function() {}
        };

        i18nFilter = function() {
            this.$get = function() {
                return function() {};
            };

            return this;
        };

        $provide.provider('i18nFilter', i18nFilter);
    }));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        editableElement = angular.element(
            '<span alch-confirm="item.delete(item)" show-confirm="showConfirm">' +
                '<p>Hello!</p></span>');

        scope.item = testItem;

        compile(editableElement)(scope);
        scope.$digest();

        elementScope = editableElement.scope();
    });

    it("should display confirmation buttons when showConfirm is true", function() {
        scope.showConfirm = true;
        scope.$digest();

        expect(editableElement.css('display')).not.toBe('none');
    });

    it("should not display confirmation buttons when showConfirm is false", function() {
        scope.showConfirm = false;
        scope.$digest();

        expect(editableElement.css('display')).toBe('none');
    });

    it("calls the provided function when the 'Yes' confirmation button is clicked", function() {
        spyOn(testItem, 'delete');

        editableElement.find('button.primary').click();

        expect(testItem.delete).toHaveBeenCalledWith(testItem);
    });

    it("closes the dialog when the 'No' confirmation button is clicked", function() {
        spyOn(testItem, 'delete');

        scope.showConfirm = true;
        scope.$digest();
        editableElement.find('button.secondary').click();

        expect(testItem.delete).not.toHaveBeenCalled();
        expect(scope.showConfirm).toBe(false);
        expect(editableElement.css('display')).toBe('none');
    });
});
