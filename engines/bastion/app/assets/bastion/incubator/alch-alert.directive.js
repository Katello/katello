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
            scope.alerts = [];

            function addToAlerts(messages) {
                scope.alerts = messages;
            }

            scope.$watch('successMessages', function (messages) {
                if (messages && messages.length > 0) {
                    var successMessages = _.map(messages, function (message) {
                        return {message: message, type: 'success'};
                    });
                    addToAlerts(successMessages);
                    scope.successMessages = [];
                }
            }, true);

            scope.$watch('infoMessages', function (messages) {
                if (messages && messages.length > 0) {
                    var infoMessages = _.map(messages, function (message) {
                        return {message: message, type: 'info'};
                    });
                    addToAlerts(infoMessages);
                    scope.infoMessages = [];
                }
            }, true);

            scope.$watch('warningMessages', function (messages) {
                if (messages && messages.length > 0) {
                    var warningMessages = _.map(messages, function (message) {
                        return {message: message, type: 'warning'};
                    });
                    addToAlerts(warningMessages);
                    scope.warningMessages = [];
                }
            }, true);

            scope.$watch('errorMessages', function (messages) {
                if (messages && messages.length > 0) {
                    var errorMessages = _.map(messages, function (message) {
                        return {message: message, type: 'danger'};
                    });
                    addToAlerts(errorMessages);
                    scope.errorMessages = [];
                }
            }, true);

            scope.closeAlert = function (index) {
                scope.alerts.splice(index, 1);
            };
        }
    };
});
