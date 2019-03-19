(function () {
    /**
     * @ngdoc directive
     * @name Bastion.utils.directive:stopEvent
     *
     * @description
     *   Prevents an event from propagating.  This is basically a hack to work around
     *   https://github.com/angular-ui/bootstrap/issues/2017 which causes clicks to
     *   inputs inside of ui-modal to cause a loss of focus on the input.
     *
     * @example
     *   <input type="text" stop-event="click"/>
     */

    function stopEvent() {
        return {
            restrict: 'A',
            link: function (scope, element, attr) {
                element.on(attr.stopEvent, function (e) {
                    e.stopPropagation();
                });
            }
        };
    }

    angular.module('Bastion.utils').directive('stopEvent', stopEvent);
})();
