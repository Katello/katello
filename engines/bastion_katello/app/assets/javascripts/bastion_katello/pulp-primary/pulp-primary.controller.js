/**
 * @ngdoc object
 * @name  Bastion.pulp-primary.controller:PulpPrimaryController
 *
 * @requires $scope
 * @requires $urlMatcherFactory
 * @requires $location
 * @requires PulpPrimary
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the pulp primary page.
 */
angular.module('Bastion.pulp-primary').controller('PulpPrimaryController',
    ['$scope', '$urlMatcherFactory', '$location', 'PulpPrimary', 'Notification',
    function ($scope, $urlMatcherFactory, $location, PulpPrimary, Notification) {

        var urlMatcher = $urlMatcherFactory.compile("/smart_proxies/:capsuleId");
        var capsuleId = urlMatcher.exec($location.path()).capsuleId;

        var errorHandler = function errorHandler(response) {
            angular.forEach(response.data.errors, function (error) {
                Notification.setErrorMessage(error);
            });
        };

        $scope.smartProxyId = capsuleId;

        $scope.reclaimSpace = function () {
            PulpPrimary.reclaimSpace({id: capsuleId}, function () {
                Notification.setSuccessMessage("Space reclamation task started in the background.");
            }, errorHandler);
        };
    }]
);
