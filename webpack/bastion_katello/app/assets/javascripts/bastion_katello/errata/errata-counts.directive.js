/**
 * @ngdoc directive
 * @name bastion.errata:errataCounts
 *
 * @description
 *   Directive for displaying the counts of the various types of errata.
 *
 * @example
 * <div errata-counts="contentViewVersion.errata_counts"></div>
 */
angular.module('Bastion.errata').directive('errataCounts', function () {
    return {
        restrict: 'AE',
        replace: true,
        templateUrl: 'errata/views/errata-counts.html',
        scope: {
            errataCounts: '='
        }
    };
});
