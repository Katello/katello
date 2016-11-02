/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires HostCollection
 * @requires ApiErrorHandler
 * @requires urlencodeFilter
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionDetailsController',
    ['$scope', '$state', '$q', 'translate', 'HostCollection', 'ApiErrorHandler', 'urlencodeFilter',
    function ($scope, $state, $q, translate, HostCollection, ApiErrorHandler, urlencodeFilter) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.hostCollection) {
            $scope.panel.loading = false;
        }

        $scope.hostCollection = HostCollection.get({id: $scope.$stateParams.hostCollectionId}, function (hostCollection) {
            $scope.$broadcast('hostCollection.loaded', hostCollection);
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.refreshHostCollection = function () {
            $scope.hostCollection.$get().then(function (hostCollection) {
                $scope.$emit("updateContentHostCollection", hostCollection);
            });
        };

        $scope.getHostCollectionSearchUrl = function (hostCollectionName) {
            var search = 'host_collection="%s"'.replace('%s', hostCollectionName);
            return '?select_all=true&search=' + urlencodeFilter(search);
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

        $scope.removeHostCollection = function (hostCollection) {
            hostCollection.$delete(function () {
                $scope.transitionTo('host-collections');
                $scope.successMessages.push(translate('Host Collection removed.'));
            }, function (response) {
                $scope.errorMessages.push(translate("An error occurred removing the Host Collection: ") + response.data.displayMessage);
            });
        };

    }]
);
