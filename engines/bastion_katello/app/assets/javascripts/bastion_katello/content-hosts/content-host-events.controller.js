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
    ['$scope', 'translate', 'ContentHost', 'Nutupane',
    function ($scope, translate, ContentHost, Nutupane) {
        var params = {id: $scope.$stateParams.contentHostId },
            nutupane = new Nutupane(ContentHost, params, 'events');

        $scope.eventTable = nutupane.table;

    }]
);
