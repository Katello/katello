/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostStatusController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentHost
 */
angular.module('Bastion.content-hosts').controller('ContentHostStatusController',
    ['$scope', 'translate',
    function ($scope, translate) {

        $scope.statusReason = translate("Loading...");
        $scope.statusRetrieved = false;

    }]
);
