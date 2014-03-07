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
 * @name Bastion.widgets.directive:title
 *
 * @requires PageTitle
 *
 * @description
 *   Provides a way to set the title of the page.
 */
angular.module('Bastion.widgets').directive('pageTitle', ['PageTitle', function (PageTitle) {
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
                transclude(scope, function (clone) {
                    title = clone.text();
                });

                if (ngModel) {
                    var unbind = scope.$watch(function () {
                        return ngModel.$viewValue;
                    }, function (model) {
                        unbind();
                        if (model.hasOwnProperty('$promise')) {
                            model.$promise.then(function (model) {
                                scope[scope.modelName] = model;
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
