(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.host-collections.controller:HostCollectionCopyController
     *
     * @description
     *   For copying a host collection.
     *
     * @requires translate
     *
     */
    function HostCollectionCopyController($scope, Notification, HostCollection, translate) {
        $scope.copy = function (newName) {
            HostCollection.copy({id: $scope.$stateParams.hostCollectionId, 'host_collection': {name: newName}}, function (response) {
                $scope.transitionTo('host-collection.info', {hostCollectionId: response.id});
            }, function (response) {
                Notification.setErrorMessage(response.data.displayMessage);
            });
        };
        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Create Copy');
    }

    angular
        .module('Bastion.host-collections')
        .controller('HostCollectionCopyController', HostCollectionCopyController);

    HostCollectionCopyController.$inject = ['$scope', 'Notification', 'HostCollection', 'translate'];

})();
