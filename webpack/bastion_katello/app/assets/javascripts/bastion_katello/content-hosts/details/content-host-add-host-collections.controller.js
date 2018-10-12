/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostAddHostCollectionsController
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
 *   Provides the functionality for adding host collections to a content host.
 */
angular.module('Bastion.content-hosts').controller('ContentHostAddHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'HostCollection', 'Host', 'CurrentOrganization', 'Nutupane', 'Notification',
    function ($scope, $q, $location, translate, HostCollection, Host, CurrentOrganization, Nutupane, Notification) {
        var params, nutupane;

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true,
            'available_for': 'host',
            'host_id': $scope.$stateParams.hostId
        };

        nutupane = new Nutupane(HostCollection, params);
        $scope.controllerName = 'katello_host_collections';
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;

        $scope.addHostCollections = function (host) {
            var deferred = $q.defer(),
                success,
                error,
                data,
                hostCollections,
                hostCollectionsToAdd;

            success = function (response) {
                Notification.setSuccessMessage(translate('Added %x host collections to content host "%y".')
                    .replace('%x', $scope.table.numSelected).replace('%y', host.name));
                $scope.table.working = false;
                $scope.table.selectAll(false);
                nutupane.refresh();
                $scope.host.$get();
                deferred.resolve(response);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                Notification.setErrataIds(response.data.errors.base);
                $scope.table.working = false;
            };

            $scope.table.working = true;

            hostCollections = _.map(host['host_collections'], 'id');
            hostCollectionsToAdd = _.map($scope.table.getSelected(), 'id');
            data = {"host_collection_ids": _.union(hostCollections, hostCollectionsToAdd)};

            Host.updateHostCollections({id: host.id}, data, success, error);

            return deferred.promise;
        };
    }]
);
