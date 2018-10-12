/**
 * @ngdoc directive
 * @name  Bastion.tasks.directive:taskInputPart
 *
 * @description
 *   Converts part of task humanized structure into a link if possible
 */
angular.module('Bastion.tasks').directive('taskInputPart',
    function () {
        return {
            restrict: 'A',
            template: '<span ng-if="!link()">{{text()}}</span>' +
                      '<a ng-if="link()" href="{{link()}}">{{text()}}</a>',
            scope: {
                data: '='
            },
            link: function (scope) {
                scope.text = function () {
                    if (_.isString(scope.data)) {
                        return scope.data;
                    }

                    return scope.data[1].text;
                };

                scope.link = function () {
                    if (!_.isString(scope.data) && scope.data[1]) {
                        return scope.data[1].link;
                    }
                };
            }
        };
    }
);
