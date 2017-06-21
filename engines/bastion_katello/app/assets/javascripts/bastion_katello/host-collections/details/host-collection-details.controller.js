/**
 * @ngdoc object
 * @name  Bastion.host-collections.controller:HostCollectionDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires Host
 * @requires ContentHostsModalHelper
 * @requires HostCollection
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionDetailsController',
    ['$scope', '$state', '$q', 'translate', 'Host', 'ContentHostsModalHelper', 'HostCollection', 'ApiErrorHandler',
    function ($scope, $state, $q, translate, Host, ContentHostsModalHelper, HostCollection, ApiErrorHandler) {
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

        $scope.getHostIds = function() {
            return $scope.selected;
        };

        $scope.host = Host.get({search: "host_collection_id = " + $scope.$stateParams.hostCollectionId}, function (response) {
            $scope.selected = {
                included: {
                    ids: _.map(response.results, 'id')
                },
                excluded: {
                    ids: []
                }};
        ContentHostsModalHelper.resolveFunc = $scope.getHostIds;}, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.refreshHostCollection = function () {
            $scope.hostCollection.$get().then(function (hostCollection) {
                $scope.$emit("updateContentHostCollection", hostCollection);
            });
        };

        $scope.openPackagesModal = function () {
            ContentHostsModalHelper.openPackagesModal();
        };

        $scope.openErrataModal = function () {
            ContentHostsModalHelper.openErrataModal();
        };

        $scope.openHostCollectionsModal = function () {
            ContentHostsModalHelper.openHostCollectionsModal();
        };


        $scope.openEnvironmentModal = function () {
            ContentHostsModalHelper.openEnvironmentModal();
        };


        $scope.openSubscriptionsModal = function () {
            ContentHostsModalHelper.openSubscriptionsModal();
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
