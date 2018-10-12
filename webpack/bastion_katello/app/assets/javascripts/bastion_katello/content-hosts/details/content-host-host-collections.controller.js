/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostHostCollectionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires HostCollection
 * @requires Host
 * @requires CurrentOrganization
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the list host collections details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'HostCollection', 'Host', 'CurrentOrganization', 'Nutupane', 'Notification',
    function ($scope, $q, $location, translate, HostCollection, Host, CurrentOrganization, Nutupane, Notification) {
        var nutupane, params;

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true,
            'host_id': $scope.$stateParams.hostId
        };

        nutupane = new Nutupane(HostCollection, params);
        $scope.controllerName = 'katello_host_collections';
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;

        $scope.removeHostCollections = function (host) {
            var deferred = $q.defer(),
                success,
                error,
                data,
                hostCollections,
                hostCollectionsToRemove;

            success = function (response) {
                var message = translate('Removed %x host collections from content host "%y".')
                    .replace('%x', $scope.table.numSelected).replace('%y', host.name);

                Notification.setSuccessMessage(message);
                $scope.table.working = false;
                $scope.table.selectAll(false);
                nutupane.refresh();
                $scope.host.$get();
                deferred.resolve(response);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                angular.forEach(response.data.errors, function (responseError) {
                    Notification.setErrorMessage(responseError);
                });
                $scope.table.working = false;
            };

            $scope.table.working = true;
            hostCollections = _.map(host['host_collections'], 'id');
            hostCollectionsToRemove = _.map($scope.table.getSelected(), 'id');

            data = {"host_collection_ids": _.difference(hostCollections, hostCollectionsToRemove)};
            Host.updateHostCollections({id: host.id}, data, success, error);

            return deferred.promise;
        };
    }]
);
