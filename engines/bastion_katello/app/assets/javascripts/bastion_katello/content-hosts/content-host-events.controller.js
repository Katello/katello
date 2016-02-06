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
        var params = {id: $scope.$stateParams.hostId},
            nutupane = new Nutupane(HostSubscription, params, 'events');
        $scope.eventTable = nutupane.table;
    }]
);
