/**
 * Copyright 2014 Red Hat, Inc.
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

/**
 * @ngdoc directive
 * @name alchemy.directive:alchFormButtons
 *
 * @description
 *   Encapsulates the standard structure and styling for create and cancel buttons
 *   when used with a form.
 *
 * @example
 *      <div alch-form-buttons
             on-cancel="transitionTo('product.index')"
             on-save="save(product)"
             working="working">
        </div>
 */
angular.module('alchemy').directive('alchFormButtons', function () {
    return {
        replace: true,
        require: '^form',
        templateUrl: 'incubator/views/alch-form-buttons.html',
        scope: {
            handleCancel: '&onCancel',
            handleSave: '&onSave',
            working: '='
        },
        link: function (scope, iElement, iAttrs, controller) {

            if (scope.working === undefined) {
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
