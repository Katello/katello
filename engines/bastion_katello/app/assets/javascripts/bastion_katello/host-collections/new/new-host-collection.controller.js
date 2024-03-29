/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:NewHostCollectionController
 *
 * @requires $scope
 * @requires HostCollection
 * @requires CurrentOrganization
 * @requires translate
 *
 * @description
 *   Controls the creation of an empty HostCollection object for use by sub-controllers.
 */
angular.module('Bastion.host-collections').controller('NewHostCollectionController',
    ['$scope', 'HostCollection', 'CurrentOrganization', 'translate',
    function ($scope, HostCollection, CurrentOrganization, translate) {

        $scope.hostCollection = new HostCollection();
        $scope.panel = {loading: false};

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('New Host Collection');

        function success() {
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
