/**
 * @ngdoc directive
 * @name Bastion.components.directive:pathSelector
 *
 * @description
 *   Provides a widget that renders a set of paths visually and allows
 *   users to select one or more paths depending on the configuration set.
 *
 * @example
 */
angular.module('Bastion.components').directive('pathSelector',
    function () {
    return {
        restrict: 'AE',
        require: '?ngModel',
        scope: {
            paths: '=pathSelector',
            mode: '@',
            disabled: '=',
            disableTrigger: '=',
            pathAttribute: '@'
        },
        templateUrl: 'components/views/path-selector.html',
        link: function (scope, element, attrs, ngModel) {
            var activeItemId, convertPathObjects, selectionRequired;
            selectionRequired = attrs.selectionRequired ? attrs.selectionRequired === 'true' : true;

            function forEachItem(callback) {
                angular.forEach(scope.paths, function (path) {
                    angular.forEach(path, function (item) {
                        callback(item);
                    });
                });
            }

            function selectById(id) {
                forEachItem(function (item) {
                    if (item.id === id) {
                        ngModel.$setViewValue(item);
                        item.selected = true;
                    }
                });
            }

            function unselectActive() {
                forEachItem(function (item) {
                    if (item.id === activeItemId) {
                        item.selected = false;
                    }
                });
            }

            scope.itemChanged = function (item) {
                if (item && scope.mode === 'singleSelect') {
                    if (item.selected || selectionRequired) {
                        unselectActive();
                        selectById(item.id);
                        activeItemId = item.id;
                    } else {
                        ngModel.$setViewValue(undefined);
                    }
                }
            };

            convertPathObjects = function (paths) {
                if (scope.pathAttribute) {
                    paths = _.map(paths, scope.pathAttribute);
                }
                return paths;
            };

            if (scope.paths.$promise) {
                scope.paths.$promise.then(function (paths) {
                    scope.paths = convertPathObjects(paths);
                    scope.itemChanged(ngModel.$modelValue);
                });
            } else {
                scope.paths = convertPathObjects(scope.paths);
                scope.itemChanged(ngModel.$modelValue);
            }

            ngModel.$render = function () {
                if (ngModel.$modelValue) {
                    ngModel.$modelValue.selected = true;
                    scope.itemChanged(ngModel.$modelValue);
                }
            };

            scope.$watch('disableTrigger', function (disable) {
                forEachItem(function (item) {
                    item.disabled = disable;
                });
            });
        }
    };
});
