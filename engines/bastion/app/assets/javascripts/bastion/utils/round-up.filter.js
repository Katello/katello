(function () {
    /**
     * @ngdoc filter
     * @name Bastion.utils.filter:roundUp
     *
     * @description
     *  Converts an ng-model to a number.
     *
     * @example
     *   {{ 107.5 | roundUp }}
     */

    function roundUp() {
        return function (value) {
            return Math.ceil(value);
        };
    }

    angular.module('Bastion.utils').filter('roundUp', roundUp);
})();
