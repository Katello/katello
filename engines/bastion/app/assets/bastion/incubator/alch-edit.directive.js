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
    .controller('AlchEditController', ['$scope', '$filter', function($scope, $filter) {
        var previousValue;

        $scope.edit = function() {
            var options;

            if ($scope.readonly !== true) {
                $scope.editMode = true;
                previousValue = $scope.model;

                if ($scope.handleOptions !== undefined) {
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
            var action = $scope.handleSave({ value: $scope.model });
            $scope.editTrigger = false;
            handleAction(action);
        };

        $scope.add = function() {
            var action = $scope.handleAdd({ value: $scope.model });
            handleAction(action);
        };

        $scope.remove = function() {
            var action = $scope.handleRemove({ value: $scope.model });
            handleAction(action);
        };

        function handleAction(action) {
            $scope.editMode = false;
            $scope.workingMode = true;

            if (action !== undefined && action.hasOwnProperty('then')) {
                action.then(
                    function() {
                        $scope.updateDisplay($scope.model);
                        $scope.workingMode = false;
                    },
                    function() {
                        $scope.workingMode = false;
                        $scope.editMode = true;
                    }
                );

            } else {
                $scope.workingMode = false;
            }
        }

        $scope.cancel = function() {
            $scope.editMode = false;
            $scope.disableSave = false;
            $scope.model = previousValue;
            $scope.handleCancel({ value: $scope.model });
        };

        $scope.delete = function($event) {
            var handleDelete;

            // Need to prevent click $event from propagating to edit handler
            $event.stopPropagation();

            $scope.editMode = false;
            $scope.workingMode = true;

            handleDelete = $scope.handleDelete({ value: $scope.model });

            if (handleDelete !== undefined && handleDelete.hasOwnProperty('then')) {

                handleDelete.then(
                    function() {
                        $scope.updateDisplay($scope.model);
                        $scope.workingMode = false;
                    },
                    function() {
                        $scope.workingMode = false;
                        $scope.editMode = true;
                    }
                );
            } else {
                $scope.workingMode = false;
            }
        };

        $scope.$watch('editTrigger', function(edit) {
            if (edit) {
                $scope.edit();
            }
        });

        $scope.updateDisplay = function (newValue) {
            if ($scope.formatter) {
                $scope.displayValue = $filter($scope.formatter)(newValue, $scope.formatterOptions);
            } else {
                $scope.displayValue = $scope.model;
            }
            if ($scope.displayValue && $scope.displayValueDefault) {
                $scope.displayValue = $scope.displayValueDefault;
            }
        };

        // Watch the model and displayed values for changes
        // and update the displayed value accordingly.
        $scope.$watch('model + displayValue', function(newValue) {
            if (newValue) {
                $scope.updateDisplay($scope.model);
            }
        });

        // Watch forcedWorkingMode and update the working mode
        // accordingly.  This allows a user to set working mode.
        $scope.$watch('forcedWorkingMode', function(newValue) {
            $scope.workingMode = newValue;
        });
    }])
    .directive('alchEditText', function() {
        return {
            replace: true,
            scope: {
                model: '=alchEditText',
                readonly: '=',
                handleSave: '&onSave',
                handleCancel: '&onCancel',
                deletable: '@deletable',
                handleDelete: '&onDelete'
            },
            templateUrl: 'incubator/views/alch-edit-text.html'
        };
    })
    .directive('alchEditTextarea', function() {
        return {
            replace: true,
            scope: {
                model: '=alchEditTextarea',
                readonly: '=',
                handleSave: '&onSave',
                handleCancel: '&onCancel'
            },
            templateUrl: 'incubator/views/alch-edit-textarea.html'
        };
    })
    .directive('alchEditCheckbox', function() {
        return {
            replace: true,
            scope: {
                model: '=alchEditCheckbox',
                readonly: '=',
                handleSave: '&onSave',
                handleCancel: '&onCancel'
            },
            templateUrl: 'incubator/views/alch-edit-textarea.html'
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
                handleSave: '&onSave',
                handleCancel: '&onCancel',
                editTrigger: '='
            },
            templateUrl: 'incubator/views/alch-edit-select.html',
            compile: function(element, attrs) {
                var optionsFormat = attrs['optionsFormat'];
                if (optionsFormat) {
                    element.find('select').attr('ng-options', optionsFormat);
                }
            }
        };
    })
    .directive('alchEditMultiselect', function() {
        return {
            replace: true,
            templateUrl: 'incubator/views/alch-edit-multiselect.html',
            scope: {
                model: '=alchEditMultiselect',
                formatter: '@formatter',
                formatterOptions: '@formatterOptions',
                handleOptions: '&options',
                handleSave: '&onSave',
                handleAdd: '&onAdd',
                handleRemove: '&onRemove',
                handleCancel: '&onCancel',
                buttonConfig: '@buttonConfig',
                forcedWorkingMode: '=',
                displayValueDefault: '@displayValueDefault'
            },
            controller: 'AlchEditMultiselectController'
        };
    })
    .controller('AlchEditMultiselectController', ['$scope', function($scope) {
        var unbindWatcher, checkPrevious, getIds;

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
        };

        // Set the checkboxes for already selected items and then unbind.
        unbindWatcher = $scope.$watch("model + options", function() {
            if (!$scope.model || !$scope.options) {
                return;
            }
            checkPrevious();
            unbindWatcher();
        });
    }])
    .directive('alchEditAddItem', function() {
        return {
            templateUrl: 'incubator/views/alch-edit-add-item.html',
            scope: {
                model: '=alchEditAddItem',
                handleAdd: '&onAdd'
            },
            controller: 'AlchEditAddItemController'
        };
    })
    .controller('AlchEditAddItemController', ['$scope', function($scope) {
        $scope.add = function(value) {
            var handleAdd;

            $scope.workingMode = true;

            handleAdd = $scope.handleAdd(value);

            if (handleAdd !== undefined && handleAdd.hasOwnProperty('then')) {

                handleAdd.then(
                    function() {
                        $scope.workingMode = false;
                        $scope.newKey = null;
                        $scope.newValue = null;
                    },
                    function() {
                        $scope.workingMode = false;
                    }
                );
            } else {
                $scope.workingMode = false;
                $scope.newKey = null;
                $scope.newValue = null;
            }
        };
    }]);
