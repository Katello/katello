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
 *
 * @description
 *   Provides the functionality for the list host collections details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'HostCollection', 'Host', 'CurrentOrganization', 'Nutupane',
    function ($scope, $q, $location, translate, HostCollection, Host, CurrentOrganization, Nutupane) {
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

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.removeHostCollections = function (host) {
            var deferred = $q.defer(),
                success,
                error,
                data,
                hostCollections,
                hostCollectionsToRemove;

            success = function (response) {
                $scope.successMessages = [translate('Removed %x host collections from content host "%y".')
                    .replace('%x', $scope.table.numSelected).replace('%y', host.name)];
                $scope.table.working = false;
                $scope.table.selectAll(false);
                nutupane.refresh();
                $scope.host.$get();
                deferred.resolve(response);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                $scope.errorMessages = response.data.errors;
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
