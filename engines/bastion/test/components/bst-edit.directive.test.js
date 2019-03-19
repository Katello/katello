describe('Directive: bstEdit', function() {
    var scope,
        compile,
        testItem;

    beforeEach(module('Bastion.components',
        'Bastion.components.formatters',
        'components/views/bst-edit.html',
        'components/views/bst-edit-text.html',
        'components/views/bst-edit-textarea.html',
        'components/views/bst-edit-number.html',
        'components/views/bst-edit-select.html',
        'components/views/bst-edit-add-item.html',
        'components/views/bst-edit-checkbox.html',
        'components/views/bst-edit-add-remove-cancel.html',
        'components/views/bst-edit-multiselect.html',
        'components/views/bst-edit-save-cancel.html'));

    beforeEach(module(function($provide) {
        testItem = {
            name: 'Test Name',
            taco: 'carnitas',
            add: function () {},
            save: function() {},
            revert: function() {},
            delete: function() {}
        };

        translate = function() {
            this.$get = function() {
                return function() {};
            };

            return this;
        };

        $provide.provider('translate', translate);
        $provide.provider('translateFilter', translate);
    }));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    describe('bstEdit controller', function() {
        var editController;

        beforeEach(inject(function($controller) {
            editController = $controller('BstEditController', {$scope: scope});
        }));

    });

    describe('bstEdit directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span bst-edit-text="item.name" on-save="item.save()" on-delete="item.delete()" ' +
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

            expect(element.hasClass('ng-hide')).toBe(false);
            element.trigger('click');

            expect(element.hasClass('ng-hide')).toBe(true);
        });

        it("should call the method set to on-save when clicking save button", function() {
            var element = editableElement.find('[ng-click="save()"]');
            spyOn(testItem, 'save');

            element.trigger('click');

            expect(testItem.save).toHaveBeenCalled();
        });

        it("should call the method set to on-delete when clicking delete button", function() {
            var element = editableElement.find('.fa-remove');
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
                elementScope = editableElement.isolateScope();
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

    describe('bstEditText directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span bst-edit-text="item.name"></span>');

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

    describe('bstEditCheckbox directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span bst-edit-checkbox="item.name"></span>');

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

    describe('bstEditTextarea directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span bst-edit-textarea="item.name"></span>');

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

    describe('bstEditNumber directive', function() {
        var editableElement;

        it("should display an input with type of number on editable click", function() {
            editableElement = angular.element(
                '<span bst-edit-number="number"></span>');

            scope.number = 3;

            compile(editableElement)(scope);
            scope.$digest();

            var element = editableElement.find('.editable'),
                input = editableElement.find('input');
            element.trigger('click');

            expect(input.css('display')).not.toBe('none');
            expect(input.attr('type')).toBe('number');
        });

        it("should display an input with type of number on editable click with min and max", function() {
            editableElement = angular.element(
                '<span bst-edit-number="number" min=123 max=456></span>');

            scope.number = 123;

            compile(editableElement)(scope);
            scope.$digest();

            var element = editableElement.find('.editable'),
                input = editableElement.find('input');
            element.trigger('click');

            expect(input.css('display')).not.toBe('none');
            expect(input.attr('type')).toBe('number');
            expect(input.attr('min')).toBe('123');
            expect(input.attr('max')).toBe('456');
        });

    });

    describe('bstEditSelect directive', function() {
        var editableElement;

        beforeEach(function() {
            scope.tacoOptions = [{id: 1, name: 'Carnitas'}, {id: 2, name: 'Tilapia'}];

            editableElement = angular.element(
                '<span bst-edit-select="item.taco" options="tacoOptions" ></span>'
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

    describe('bstEditMultiselect directive', function() {
        var editableElement,
            directiveScope,
            multiSelectController;

        beforeEach(function() {
            editableElement = angular.element(
                '<span bst-edit-multiselect="tacos" options="tacoOptions"></span>');

            scope.tacos = [{id: 2, name: 'barbacoa'}, {id: 3, name: 'carnitas'}];
            scope.tacoOptions = [{id: 1, name: 'baja shrimp'}, {id: 2, name: 'barbacoa'},
                {id: 3, name: 'carnitas'}, {id: 4, name: 'spicy tinga chicken'}];

            compile(editableElement)(scope);
            scope.$digest();
            directiveScope = editableElement.isolateScope();
        });

        beforeEach(inject(function($controller) {
            multiSelectController = $controller('BstEditMultiselectController', {$scope: directiveScope});
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

    describe('bstEditAddItem directive', function() {
        var editableElement;

        beforeEach(function() {
            editableElement = angular.element(
                '<span bst-edit-add-item="item.name" on-add="item.add()"></span>');

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
