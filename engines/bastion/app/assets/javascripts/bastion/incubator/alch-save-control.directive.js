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
 **/

/**
 * @ngdoc directive
 * @name alchemy.directive:alchSaveButton
 *
 * @description
 *   Simple directive for encapsulating create and cancel buttons. This includes states
 *   for disabling buttons and setting a visual working state.
 *
 * @example
 *   <pre>
 *     <div alch-save-control
 *          on-cancel="closeItem()"
 *          on-save="save(product)"
 *          invalid="productForm.$invalid">
 *     </div>
 */
angular.module('alchemy').directive('alchSaveControl', function () {
    return {
        restrict: 'AE',
        replace: true,
        templateUrl: 'incubator/views/alch-save-control.html',
        scope: {
            handleSave: '&onSave',
            handleCancel: '&onCancel',
            invalid: '=',
            working: '='
        }
    };
});
