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
 * @name alchemy.directive:alchEdit
 * @restrict A
 *
 * @description
 *   Provides a set of inline editable elements for various form elements. The
 *   alch-edit directive is the base for all input types to take advantage of
 *   and should never be used directly. The current list of supported types are:
 *
 *   - input (alch-edit-text)
 *   - textarea (alch-edit-textarea)
 *
 * @example
 */
angular.module('alchemy')
    .directive('alchEdit', function() {
        return {
            replace: true,
            controller: 'AlchEditController',
            templateUrl: 'incubator/views/alch-edit.html'
        };
    })
    .controller('AlchEditController', ['$scope', function($scope) {
        var previousValue;

        $scope.edit = function() {
            $scope.editMode = true;
            previousValue = $scope.model;
        };

        $scope.save = function() {
            $scope.editMode = false;
            $scope.handleSave({ value: $scope.model });
        };

        $scope.cancel = function() {
            $scope.editMode = false;
            $scope.model = previousValue;
            $scope.handleCancel({ value: $scope.model });
        };
    }])
    .directive('alchEditText', function() {
        return {
            replace: true,
            scope: {
                model: '=alchEditText',
                handleSave: '&onSave',
                handleCancel: '&onCancel'
            },
            template: '<div>' +
                        '<input ng-model="model" ng-show="editMode">' +
                        '<div alch-edit></div>' +
                      '</div>'
        };
    })
    .directive('alchEditTextarea', function() {
        return {
            replace: true,
            scope: {
                model: '=alchEditTextarea',
                handleSave: '&onSave',
                handleCancel: '&onCancel'
            },
            template: '<div>' +
                        '<textarea rows=8 cols=40 ng-model="model" ng-show="editMode"></textarea>' +
                        '<div alch-edit></div>' +
                      '</div>'
        };
    });
