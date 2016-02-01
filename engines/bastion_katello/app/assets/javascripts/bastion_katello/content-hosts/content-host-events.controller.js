/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostEventsController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentHost
 * @requires Nutupane
 */
angular.module('Bastion.content-hosts').controller('ContentHostEventsController',
    ['$scope', 'translate', 'HostSubscription', 'Nutupane',
    function ($scope, translate, HostSubscription, Nutupane) {
        $scope.eventTable = {};
        $scope.contentHost.$promise.then(function() {
            var params = {id: $scope.contentHost.host.id },
                nutupane = new Nutupane(HostSubscription, params, 'events');

            $scope.eventTable = nutupane.table;
            nutupane.refresh();
        });
    }]
);
