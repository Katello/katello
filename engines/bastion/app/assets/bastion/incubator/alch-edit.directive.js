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
            var options;

            if ($scope.readonly !== true) {
                $scope.editMode = true;
                previousValue = $scope.displayValue;

                if ($scope.handleOptions !== undefined && !$scope.options) {
                    options = $scope.handleOptions();
                }

                if (options !== undefined) {
                    if (options.hasOwnProperty('then')) {
                        options.then(function(data) {
                            $scope.options = data;

                            if ($scope.options.length === 0) {
                                $scope.disableSave = true;
                            }
                        });
                    } else {
                        $scope.options = options;

                        if ($scope.options.length === 0) {
                            $scope.disableSave = true;
                        }
                    }

                }
            }
        };

        $scope.save = function() {
            var handleSave;

            $scope.editMode = false;
            $scope.savingMode = true;

            handleSave = $scope.handleSave({ value: $scope.model });

            if (handleSave !== undefined && handleSave.hasOwnProperty('then')) {

                handleSave.then(
                    function() {
                        $scope.savingMode = false;
                    },
                    function() {
                        $scope.savingMode = false;
                        $scope.editMode = true;
                    }
                );
            }
        };

        $scope.cancel = function() {
            $scope.editMode = false;
            $scope.disableSave = false;
            $scope.displayValue = previousValue;
            $scope.handleCancel({ value: $scope.model });
        };

        $scope.$watch('editTrigger', function(edit) {
            if (edit) {
                $scope.edit();
            }
        });
    }])
    .directive('alchEditText', function() {
        return {
            replace: true,
            scope: {
                model: '=alchEditText',
                readonly: '=',
                displayValue: '=alchEditText',
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
                readonly: '=',
                displayValue: '=alchEditTextarea',
                handleSave: '&onSave',
                handleCancel: '&onCancel'
            },
            template: '<div>' +
                        '<textarea rows=8 cols=40 ng-model="model" ng-show="editMode"></textarea>' +
                        '<div alch-edit></div>' +
                      '</div>'
        };
    })
    .directive('alchEditSelect', function() {
        return {
            replace: true,
            scope: {
                model: '=alchEditSelect',
                readonly: '=',
                selector: '=',
                handleOptions: '&options',
                displayValue: '=alchEditSelect',
                handleSave: '&onSave',
                handleCancel: '&onCancel',
                editTrigger: '='
            },
            template: '<div>' +
                        '<select ng-model="selector" ' +
                                 'ng-options="option.id as option.name for option in options" ' +
                                 'ng-show="editMode">' +
                        '</select>' +
                        '<div alch-edit></div>' +
                      '</div>'
        };
    })
    .directive('alchEditMultiselect', function() {
        return {
            replace: true,
            templateUrl: 'incubator/views/alch-edit-multiselect.html',
            scope: {
                model: '=alchEditMultiselect',
                handleOptions: '&options',
                handleSave: '&onSave',
                handleCancel: '&onCancel'
            },
            controller: 'AlchEditMultiselectController'
        };
    })
    .controller('AlchEditMultiselectController', ['$scope', function($scope) {
        var unbindWatcher, checkPrevious, formatDisplay, getIds;

        formatDisplay = function(toFormat) {
            toFormat = toFormat || [];
            return _.pluck(toFormat, 'name').join(', ');
        };

        getIds = function(models) {
            models = models || [];
            return _.pluck(models, "id");
        };

        checkPrevious = function() {
            _.each($scope.options, function(tag) {
                var appliedIds = getIds($scope.model);
                if (_.contains(appliedIds, tag.id, 0)) {
                    tag.selected = true;
                } else {
                    tag.selected = false;
                }
            });
        };

        $scope.toggleOption = function(option) {
            var appliedIds = getIds($scope.model),
                position = _.indexOf(appliedIds, option.id, 0);

            if (position >= 0) {
                option.selected = false;
                $scope.model.splice(position, 1);
            } else {
                option.selected = true;
                $scope.model.push(option);
            }
            $scope.displayValue = formatDisplay($scope.model);
        };

        $scope.$watch("model", function(modelValue) {
            if (!modelValue) {
                return;
            }
            $scope.displayValue = formatDisplay(modelValue);
        });

        // Set the checkboxes for already selected items and then unbind.
        unbindWatcher = $scope.$watch("model + options", function() {
            if (!$scope.model || !$scope.options) {
                return;
            }
            checkPrevious();
            unbindWatcher();
        });
    }]);
