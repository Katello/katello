/**
 * @ngdoc directive
 * @name Bastion.components.directive:bstFormGroup
 *
 * @description
 *  Encapsulates the structure and styling for a label + input used within a
 *  Bootstrap3 based form.
 *
 * @example
 *  <div bst-form-group label="{{ 'Name' | translate }}" required>
        <input id="name"
               name="name"
               ng-model="product.name"
               type="text"
               tabindex="1"
               required/>
    </div>
 */
angular.module('Bastion.components').directive('bstFormGroup', function () {
    function getInput(element) {
        // table is used for bootstrap3 date/time pickers
        var input = element.find('table');

        if (input.length === 0) {
            input = element.find('input');

            if (input.length === 0) {
                input = element.find('select');

                if (input.length === 0) {
                    input = element.find('textarea');
                }
            }
        }
        return input;
    }

    return {
        transclude: true,
        replace: true,
        require: '^form',
        templateUrl: 'components/views/bst-form-group.html',
        scope: {
            'label': '@',
            'field': '@'
        },
        link: function (scope, iElement, iAttrs, controller) {
            var input = getInput(iElement),
                type = input.attr('type'),
                field;

            if (!scope.field) {
                scope.field = input.attr('id');
            }
            field = scope.field;

            if (['checkbox', 'radio', 'time'].indexOf(type) === -1) {
                input.addClass('form-control');
            }

            if (input.attr('required')) {
                iElement.addClass('required');
            }

            if (controller[field]) {
                scope.error = controller[field].$error;
            }

            scope.hasErrors = function () {
                return controller[field] && controller[field].$invalid && controller[field].$dirty;
            };
        }
    };
});
