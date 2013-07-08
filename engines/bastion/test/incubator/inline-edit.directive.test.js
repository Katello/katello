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


describe('Directive: alchEdit', function() {
    var scope,
        compile,
        testItem;

    beforeEach(module('alchemy', 'incubator/views/alch-edit.html'));

    beforeEach(module(function($provide) {
        testItem = {
            name: 'Test Name',
            taco: 'carnitas',
            save: function() {},
            revert: function() {}
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

    describe('alchTable controller', function() {
        var element,
            editController;

        beforeEach(inject(function($controller) {
            editController = $controller('AlchEditController', {$scope: scope});
        }));

    });

    describe('alchEdit directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span alch-edit-text="item.name" on-save="item.save()" on-cancel="item.revert()"></span>');

            scope.item = testItem;

            compile(editableElement)(scope);
            scope.$digest();
        });

        it("should show the attribute passed in to the directive", function() {
            var element = editableElement.find('.editable-value');

            expect(element.text()).toBe(testItem.name);
        });

        it("should hide the editable value display on click", function() {
            var element = editableElement.find('.editable');

            expect(element.css('display')).not.toBe('none');
            element.trigger('click');

            expect(element.css('display')).toBe('none');
        });

        it("should call the method set to on-save when clicking save button", function() {
            var element = editableElement.find('[ng-click="save()"]');
            spyOn(testItem, 'save');

            element.trigger('click');

            expect(testItem.save).toHaveBeenCalled();
        });

        it("should call the method set to on-cancel when clicking cancel button", function() {
            var element = editableElement.find('[ng-click="cancel()"]');
            spyOn(testItem, 'revert');

            element.trigger('click');

            expect(testItem.revert).toHaveBeenCalled();
        });

    });

    describe('alchEditText directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span alch-edit-text="item.name"></span>');

            scope.item = testItem;

            compile(editableElement)(scope);
            scope.$digest();
        });

        it("should display an input box on editable click", function() {
            var element = editableElement.find('.editable'),
                input = editableElement.find('input');
            element.trigger('click');

            expect(input.css('display')).not.toBe('none');
        });

    });

    describe('alchEditTextarea directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span alch-edit-textarea="item.name"></span>');

            scope.item = testItem;
            scope.tacoOptions = ['baja shrimp', 'barbacoa', 'carnitas', 'spicy tinga chicken'];

            compile(editableElement)(scope);
            scope.$digest();
        });

        it("should display a textarea on editable click", function() {
            var element = editableElement.find('.editable'),
                input = editableElement.find('textarea');
            element.trigger('click');

            expect(input.css('display')).not.toBe('none');
        });

    });

    describe('alchEditSelect directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span alch-edit-select="item.taco" options="tacoOptions"></span>');

            scope.item = testItem;

            compile(editableElement)(scope);
            scope.$digest();
        });

        it("should display a select on editable click", function() {
            var element = editableElement.find('.editable'),
                input = editableElement.find('select');
            element.trigger('click');

            expect(input.css('display')).not.toBe('none');
        });

    });
});
