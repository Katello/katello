(function () {
    'use strict';

    /**
     * @ngdoc directive
     * @name  Bastion.components.directive:bstOnEnter
     *
     * @description
     *   Allows setting an action to be performed when the user presses the enter button.
     */
    function bstOnEnter() {
        return {
            scope: true,
            link: function (scope, element, attrs) {
                element.bind('keydown keypress', function (event) {
                    if (event.which === 13) {
                        scope.$apply(attrs.bstOnEnter);
                        event.preventDefault();
                    }
                });
            }
        };
    }

    angular
        .module('Bastion.components')
        .directive('bstOnEnter', bstOnEnter);

})();
