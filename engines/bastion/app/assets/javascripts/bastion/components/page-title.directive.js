/**
 * @ngdoc directive
 * @name Bastion.components.directive:title
 *
 * @requires PageTitle
 *
 * @description
 *   Provides a way to set the title of the page.
 */
angular.module('Bastion.components').directive('pageTitle', ['PageTitle', function (PageTitle) {
    return {
        templateUrl: '',
        replace: true,
        transclude: true,
        require: '?ngModel',
        scope: {
            modelName: '@ngModel'
        },
        compile: function (element, attrs, transclude) {
            var title;

            return function (scope, iElem, iAttrs, ngModel) {
                var unbind;

                transclude(scope, function (clone) {
                    title = clone.text();
                });

                if (ngModel) {
                    unbind = scope.$watch(function () {
                        return ngModel.$viewValue;
                    }, function (model) {
                        unbind();
                        if (model.hasOwnProperty('$promise')) {
                            model.$promise.then(function (data) {
                                scope[scope.modelName] = data;
                                PageTitle.setTitle(title, scope);
                            });
                        } else {
                            scope[scope.modelName] = model;
                            PageTitle.setTitle(title, scope);
                        }
                    });
                } else {
                    PageTitle.setTitle(title, scope);
                }
            };
        }
    };
}]);
