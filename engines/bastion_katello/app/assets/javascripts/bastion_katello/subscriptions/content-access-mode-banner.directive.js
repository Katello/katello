/**
 * @ngdoc directive
 * @name Bastion.subscriptions:contentAccessModeBanner
 *
 * @requires contentAccessMode
 *
 * @description
 *   Component for showing information about content access mode (whether content is
 *   allowed with or without a subscription)
 */
angular.module('Bastion.subscriptions').directive('contentAccessModeBanner',
    ['contentAccessMode',
    function (contentAccessMode) {
        return {
            restrict: 'AE',
            controller: ['$scope', function ($scope) {
                $scope.contentAccessMode = contentAccessMode;
            }],
            templateUrl: 'subscriptions/views/content-access-mode-banner.html'
        };
    }
]);
