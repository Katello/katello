/**
 * @ngdoc directive
 * @name Bastion.components.directive:bstFormButtons
 *
 * @description
 *   Encapsulates the standard structure and styling for create and cancel buttons
 *   when used with a form.
 *
 * @example
 *      <div bst-form-buttons
             on-cancel="transitionTo('product.index')"
             on-save="save(product)"
             working="working">
        </div>
 */
angular.module('Bastion.components').directive('bstFormButtons', function () {
    return {
        replace: true,
        require: '^form',
        templateUrl: 'components/views/bst-form-buttons.html',
        scope: {
            handleCancel: '&onCancel',
            handleSave: '&onSave',
            working: '='
        },
        link: function (scope, iElement, iAttrs, controller) {

            if (angular.isUndefined(scope.working)) {
                scope.working = false;
            }

            scope.isInvalid = function () {
                var invalid = controller.$invalid;

                angular.forEach(controller, function (value) {
                    if (value && value.$error) {
                        if (value.$error.server) {
                            invalid = false;
                        }
                    }
                });

                return invalid;
            };
        }
    };
});
