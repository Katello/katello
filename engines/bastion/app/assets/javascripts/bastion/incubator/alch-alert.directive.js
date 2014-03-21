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
 **/

/**
 * @ngdoc directive
 * @name alchemy.directive:alchAlert
 *
 * @description
 *   Simple directive for encapsulating alert displays.
 *
 * @example
 *   <pre>
 *     <div alch-alert
 *          successMessages="successMessages"
 *          errorMessages="errorMessages">
 *     </div>
 */
angular.module('alchemy').directive('alchAlert', function () {
    return {
        templateUrl: 'incubator/views/alch-alert.html',
        scope: {
            successMessages: '=',
            infoMessages: '=',
            warningMessages: '=',
            errorMessages: '='
        },

        link: function (scope) {
            scope.alerts = {};
            scope.types = ['success', 'info', 'warning', 'danger'];

            function handleMessages(type, messages) {
                scope.alerts[type] =  messages;
            }

            scope.$watch('successMessages', function (messages) {
                handleMessages('success', messages);
            }, true);

            scope.$watch('infoMessages', function (messages) {
                handleMessages('info', messages);
            }, true);

            scope.$watch('warningMessages', function (messages) {
                handleMessages('warning', messages);
            }, true);

            scope.$watch('errorMessages', function (messages) {
                handleMessages('danger', messages);
            }, true);

            scope.closeAlert = function (type, index) {
                scope.alerts[type].splice(index, 1);
            };
        }
    };
});
