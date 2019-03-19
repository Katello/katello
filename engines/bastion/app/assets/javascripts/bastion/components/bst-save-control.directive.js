/**
 * @ngdoc directive
 * @name Bastion.components.directive:bstSaveControl
 *
 * @description
 *   Simple directive for encapsulating create and cancel buttons. This includes states
 *   for disabling buttons and setting a visual working state.
 *
 * @example
 *   <pre>
 *     <div bst-save-control
 *          on-cancel="closeItem()"
 *          on-save="save(product)"
 *          invalid="productForm.$invalid">
 *     </div>
 */
angular.module('Bastion.components').directive('bstSaveControl', function () {
    return {
        restrict: 'AE',
        replace: true,
        templateUrl: 'components/views/bst-save-control.html',
        scope: {
            handleSave: '&onSave',
            handleCancel: '&onCancel',
            invalid: '=',
            working: '='
        }
    };
});
