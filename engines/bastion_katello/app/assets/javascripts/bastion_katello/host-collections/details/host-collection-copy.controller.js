(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.host-collections.controller:HostCollectionCopyController
     *
     * @description
     *   For copying a host collection.
     */
    function HostCollectionCopyController($scope, HostCollection) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.copy = function (newName) {
            HostCollection.copy({id: $scope.$stateParams.hostCollectionId, 'host_collection': {name: newName}}, function (response) {
                $scope.transitionTo('host-collection.info', {hostCollectionId: response.id});
            }, function (response) {
                $scope.errorMessages.push(response.data.displayMessage);
            });
        };
    }

    angular
        .module('Bastion.host-collections')
        .controller('HostCollectionCopyController', HostCollectionCopyController);

    HostCollectionCopyController.$inject = ['$scope', 'HostCollection'];

})();
