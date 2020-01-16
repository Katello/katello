/**
 * @ngdoc directive
 * @name Bastion.subscriptions:contentAccessModeBanner
 *
 * @requires simpleContentAccessEnabled
 *
 * @description
 *   Component for showing information about content access mode (whether content is
 *   allowed with or without a subscription)
 */
angular.module('Bastion.subscriptions').directive('contentAccessModeBanner',
    ['simpleContentAccessEnabled',
    function (simpleContentAccessEnabled) {
        return {
            restrict: 'AE',
            controller: ['$scope', function ($scope) {
                $scope.simpleContentAccessEnabled = simpleContentAccessEnabled;
            }],
            templateUrl: 'subscriptions/views/content-access-mode-banner.html'
        };
    }
]);
