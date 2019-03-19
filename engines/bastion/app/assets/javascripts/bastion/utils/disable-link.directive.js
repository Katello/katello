(function () {
    /**
     * @ngdoc directive
     * @name Bastion.utils.directive:disableLink
     *
     * @description
     *   Prevents links from being followed based on provided value.
     *
     * @example
     *   <a type="text" disable-link="true">Click me</a>
     */

    function disableLink() {
        return {
            compile: function (tElement, tAttrs) {
                tAttrs.ngClick = "!(" + tAttrs.disableLink + ") && (" + tAttrs.ngClick + ")";

                return function (scope, iElement, iAttrs) {
                    iElement.on("click", function (e) {
                        if (scope.$eval(iAttrs.disableLink)) {
                            e.preventDefault();
                        }
                    });
                };
            }
        };
    }

    angular.module('Bastion.utils').directive('disableLink', disableLink);
})();
