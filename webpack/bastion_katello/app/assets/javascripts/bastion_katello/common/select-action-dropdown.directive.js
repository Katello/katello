(function () {
    'use strict';

    /**
     * @ngdoc directive
     * @name Bastion.common.directive:selectActionDropdown
     *
     * @description
     *   Used to create a dropdown menu with a list of actions in it and the words "Select Action" on the button.
     *
     *   Necessary because of https://github.com/angular-ui/bootstrap/issues/5841
     *
     * @example
     *  <span select-action-dropdown>
     *    <ul>...</ul>
     *  </span>
     */
    function selectActionDropdown() {
        return {
            restrict: 'AE',
            transclude: true,
            scope: true,
            templateUrl: 'common/views/select-action-dropdown.html',
            compile: function (tElement, tAttribute, transclude) {
                return function (scope, element) {
                    scope.status = {
                        isOpen: false
                    };

                    scope.toggleDropdown = function (event) {
                        event.preventDefault();
                        event.stopPropagation();
                        scope.status.isOpen = !scope.status.isOpen;
                    };

                    transclude(scope, function(clone) {
                        element.find('.btn-group').append(clone);
                    });
                };
            }
        };
    }

    angular.module('Bastion.common').directive('selectActionDropdown', selectActionDropdown);
})();
