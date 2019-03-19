(function () {
    'use strict';

    /**
     * @ngdoc directive
     * @name Bastion.features.directive:FeatureFlag
     *
     * @description
     *   Handles checking if a given feature is enabled within HTML.
     *
     * @example
     *   HTML:
     *     <button class="btn btn-default"
     *             bst-feature-flag="custom_products"
     *             ui-sref="products.discovery.scan">
     *       <i class="fa fa-screenshot"></i>
     *       {{ "Repo Discovery" | translate }}
     *     </button>
     *
     *   Routes:
     */
    function bstFeatureFlag(ngIfDirective, FeatureFlag) {
        var ngIf = ngIfDirective[0];

        return {
            transclude: ngIf.transclude,
            priority: ngIf.priority,
            terminal: ngIf.terminal,
            restrict: ngIf.restrict,
            scope: true,
            link: function (scope, element, attrs) {
                attrs.ngIf = function () {
                    return FeatureFlag.featureEnabled(attrs.bstFeatureFlag);
                };

                ngIf.link.apply(ngIf, arguments);
            }
        };
    }

    angular
        .module('Bastion.features')
        .directive('bstFeatureFlag', bstFeatureFlag);

    bstFeatureFlag.$inject = ['ngIfDirective', 'FeatureFlag'];

})();
