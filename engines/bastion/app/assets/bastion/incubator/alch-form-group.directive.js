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

/**
 * @ngdoc directive
 * @name alchemy.directive:alchFormGroup
 *
 * @description
 *  Encapsulates the structure and styling for a label + input used within a
 *  Bootstrap3 based form.
 *
 * @example
 *  <div alch-form-group label="{{ 'Name' | translate }}" required>
        <input id="name"
               name="name"
               ng-model="product.name"
               type="text"
               tabindex="1"
               required/>
    </div>
 */
angular.module('alchemy').directive('alchFormGroup', function () {
    function getInput(element) {
        var input = element.find('input');

        if (input.length === 0) {
            input = element.find('select');

            if (input.length === 0) {
                input = element.find('textarea');
            }
        }

        return input;
    }

    return {
        transclude: true,
        replace: true,
        require: '^form',
        templateUrl: 'incubator/views/alch-form-group.html',
        scope: {
            'label': '@',
            'field': '@'
        },
        link: function (scope, iElement, iAttrs, controller) {
            var input = getInput(iElement),
                field;

            if (!scope.field) {
                scope.field = input.attr('id');
            }
            field = scope.field;

            if (input.attr('type') !== "checkbox") {
                input.addClass('form-control');
            }

            if (input.attr('required')) {
                iElement.addClass('required');
            }

            scope.error = controller[field].$error;

            scope.hasErrors = function () {
                return controller[field].$invalid && controller[field].$dirty;
            };
        }
    };
});
