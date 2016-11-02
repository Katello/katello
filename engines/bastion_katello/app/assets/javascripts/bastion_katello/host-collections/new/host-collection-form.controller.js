/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionFormController
 *
 * @requires $scope
 * @requires $q
 * @requires HostCollection
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to HostCollections for creating a new host collection
 */
angular.module('Bastion.host-collections').controller('HostCollectionFormController',
    ['$scope', '$q', 'HostCollection', 'CurrentOrganization',
    function ($scope, $q, HostCollection, CurrentOrganization) {

        function success(response) {
            $scope.table.addRow(response);
            $scope.transitionTo('host-collection.info', {hostCollectionId: $scope.hostCollection.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.hostCollectionForm[field].$setValidity('', false);
                $scope.hostCollectionForm[field].$error.messages = errors;
            });
        }

        $scope.hostCollection = $scope.hostCollection || new HostCollection();
        $scope.hostCollection['unlimited_hosts'] = true;

        $scope.save = function (hostCollection) {
            hostCollection['organization_id'] = CurrentOrganization;
            hostCollection.$save(success, error);
        };

    }]
);
