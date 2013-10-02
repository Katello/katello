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

    beforeEach(module('alchemy',
        'incubator/views/alch-edit.html',
        'incubator/views/alch-edit-add-item.html',
        'incubator/views/alch-edit-add-remove-cancel.html',
        'incubator/views/alch-edit-multiselect.html',
        'incubator/views/alch-edit-save-cancel.html'));

    beforeEach(module(function($provide) {
        testItem = {
            name: 'Test Name',
            taco: 'carnitas',
            add: function () {},
            save: function() {},
            revert: function() {},
            delete: function() {}
        };

        gettext = function() {
            this.$get = function() {
                return function() {};
            };

            return this;
        };

        $provide.provider('gettext', gettext);
        $provide.provider('translateFilter', gettext);
    }));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    describe('alchEdit controller', function() {
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
                '<span alch-edit-text="item.name" on-save="item.save()" on-delete="item.delete()" ' +
                    'on-cancel="item.revert()"></span>');

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

        it("should call the method set to on-delete when clicking delete button", function() {
            var element = editableElement.find('.icon-remove');
            spyOn(testItem, 'delete');

            element.trigger('click');

            expect(testItem.delete).toHaveBeenCalled();
        });

        it("should call the method set to on-cancel when clicking cancel button", function() {
            var element = editableElement.find('[ng-click="cancel()"]');
            spyOn(testItem, 'revert');

            element.trigger('click');

            expect(testItem.revert).toHaveBeenCalled();
        });

        describe("formats displayed values", function() {
            var $filter, elementScope;
            beforeEach(inject(function(_$filter_) {
                $filter = _$filter_;
                elementScope = editableElement.scope();
            }));

            it("by executing the provided filter on the model", function() {
                elementScope.formatter = 'uppercase';

                elementScope.model = 'new name';
                elementScope.$digest();
                expect(elementScope.displayValue).toBe('NEW NAME');
            });

            it("by defaulting to model value if no filter is provided", function() {
                expect(elementScope.displayValue).toBe(elementScope.model);
            });
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

    describe('alchEditCheckbox directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span alch-edit-checkbox="item.name"></span>');

            scope.item = testItem;

            compile(editableElement)(scope);
            scope.$digest();
        });

        it("should display an checkbox on editable click", function() {
            var element = editableElement.find('.editable'),
                input = editableElement.find('input[type=checkbox]');
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
            scope.tacoOptions = [{id: 1, name: 'Carnitas'}, {id: 2, name: 'Tilapia'}];

            editableElement = angular.element(
                '<span alch-edit-select="item.taco" options="tacoOptions" ></span>'
            );

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

        it("should create options", function() {
            var element = editableElement.find('.editable'),
                input = editableElement.find('select');
            expect(input.find('option').length).not.toBe(2);
        });

    });

    describe('alchEditMultiselect directive', function() {
        var editableElement,
            directiveScope,
            multiSelectController;

        beforeEach(function() {
            editableElement = angular.element(
                '<span alch-edit-multiselect="tacos" options="tacoOptions"></span>');

            scope.tacos = [{id: 2, name: 'barbacoa'}, {id: 3, name: 'carnitas'}];
            scope.tacoOptions = [{id: 1, name: 'baja shrimp'}, {id: 2, name: 'barbacoa'},
                {id: 3, name: 'carnitas'}, {id: 4, name: 'spicy tinga chicken'}];

            compile(editableElement)(scope);
            scope.$digest();
            directiveScope = editableElement.scope();
        });

        beforeEach(inject(function($controller) {
            multiSelectController = $controller('AlchEditMultiselectController', {$scope: directiveScope});
        }));

        it("should display a multi select on editable click", function() {
            var element = editableElement.find('.editable'),
                input = editableElement.find('div');
            element.trigger('click');
            expect(input.css('display')).not.toBe('none');
        });

        it("automatically selects the previously selected items.", function() {
            directiveScope.edit();
            directiveScope.$digest();

            expect(directiveScope.options[0].selected).toBe(false);
            expect(directiveScope.options[1].selected).toBe(true);
            expect(directiveScope.options[2].selected).toBe(true);
            expect(directiveScope.options[3].selected).toBe(false);
        });

        it("allows a way to toggle options", function() {
            directiveScope.toggleOption(scope.tacoOptions[0]);
            expect(scope.tacoOptions[0].selected).toBe(true);

            directiveScope.toggleOption(scope.tacoOptions[0]);
            expect(scope.tacoOptions[0].selected).toBe(false);
        });

    });

    describe('alchEditAddItem directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span alch-edit-add-item="item.name" on-add="item.add()"></span>');

            scope.item = testItem;

            compile(editableElement)(scope);
            scope.$digest();
        });

        it("should call the method set to on-save when clicking save button", function() {
            var element = editableElement.find('button');
            spyOn(testItem, 'add');

            element.trigger('click');

            expect(testItem.add).toHaveBeenCalled();
        });
    });

});
