/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires HostCollection
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionDetailsController',
    ['$scope', '$state', '$q', 'translate', 'HostCollection',
    function ($scope, $state, $q, translate, HostCollection) {
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.copyErrorMessages = [];

        if ($scope.hostCollection) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.hostCollection = HostCollection.get({id: $scope.$stateParams.hostCollectionId}, function (hostCollection) {
            $scope.$broadcast('hostCollection.loaded', hostCollection);
            $scope.panel.loading = false;
        });

        $scope.refreshHostCollection = function () {
            $scope.hostCollection.$get().then(function (hostCollection) {
                $scope.$emit("updateContentHostCollection", hostCollection);
            });
        };

        $scope.save = function (hostCollection) {
            var deferred = $q.defer();

            hostCollection.$update(function (response) {
                deferred.resolve(response);
                $scope.successMessages.push(translate('Host Collection updated'));
                $scope.table.replaceRow(response);
            }, function (response) {
                deferred.reject(response);
                $scope.errorMessages.push(translate("An error occurred saving the Host Collection: ") + response.data.displayMessage);
            });
            return deferred.promise;
        };

        $scope.copy = function (newName) {
            HostCollection.copy({id: $scope.hostCollection.id, 'host_collection': {name: newName}}, function (response) {
                $scope.showCopy = false;
                $scope.table.addRow(response);
                $scope.transitionTo('host-collections.details.info', {hostCollectionId: response.id});
            }, function (response) {
                $scope.copyErrorMessages.push(response.data.displayMessage);
            });
        };

        $scope.removeHostCollection = function (hostCollection) {
            var id = hostCollection.id;

            hostCollection.$delete(function () {
                $scope.removeRow(id);
                $scope.transitionTo('host-collections.index');
                $scope.successMessages.push(translate('Host Collection removed.'));
            }, function (response) {
                $scope.errorMessages.push(translate("An error occurred removing the Host Collection: ") + response.data.displayMessage);
            });
        };

    }]
);
