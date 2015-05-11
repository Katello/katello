/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:NewHostCollectionController
 *
 * @requires $scope
 * @requires HostCollection
 *
 * @description
 *   Controls the creation of an empty HostCollection object for use by sub-controllers.
 */
angular.module('Bastion.host-collections').controller('NewHostCollectionController',
    ['$scope', 'HostCollection',
    function ($scope, HostCollection) {

        $scope.hostCollection = new HostCollection();
        $scope.panel = {loading: false};

    }]
);
