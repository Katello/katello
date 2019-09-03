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
 * @requires Notification
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionDetailsController',
    ['$scope', '$state', '$q', 'translate', 'Host', 'ContentHostsModalHelper', 'HostCollection', 'Notification', 'ApiErrorHandler',
    function ($scope, $state, $q, translate, Host, ContentHostsModalHelper, HostCollection, Notification, ApiErrorHandler) {
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
            return {
                included: {
                    search: 'host_collection_id = %s'.replace('%s', $scope.$stateParams.hostCollectionId),
                    ids: $scope.hostCollection ? $scope.hostCollection.host_ids : []
                }
            };
        };

        ContentHostsModalHelper.resolveFunc = $scope.getHostIds;

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

        $scope.openModuleStreamsModal = function () {
            ContentHostsModalHelper.openModuleStreamsModal();
        };

        $scope.save = function (hostCollection) {
            var deferred = $q.defer();

            hostCollection.$update(function (response) {
                deferred.resolve(response);
                Notification.setSuccessMessage(translate('Host Collection updated'));
                $scope.table.replaceRow(response);
            }, function (response) {
                deferred.reject(response);
                Notification.setErrorMessage(translate("An error occurred saving the Host Collection: ") + response.data.displayMessage);
            });
            return deferred.promise;
        };

        $scope.removeHostCollection = function (hostCollection) {
            hostCollection.$delete(function () {
                $scope.transitionTo('host-collections');
                Notification.setSuccessMessage(translate('Host Collection removed.'));
            }, function (response) {
                Notification.setErrorMessage(translate("An error occurred removing the Host Collection: ") + response.data.displayMessage);
            });
        };

    }]
);
