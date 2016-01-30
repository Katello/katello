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
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the list host collections details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'HostCollection', 'Host', 'Nutupane',
    function ($scope, $q, $location, translate, HostCollection, Host, Nutupane) {
        var hostCollectionsPane, params;

        params = {
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true,
            'host_id': $scope.$stateParams.hostId
        };

        hostCollectionsPane = new Nutupane(HostCollection, params);
        $scope.hostCollectionsTable = hostCollectionsPane.table;

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
                    .replace('%x', $scope.hostCollectionsTable.numSelected).replace('%y', host.name)];
                $scope.hostCollectionsTable.working = false;
                $scope.hostCollectionsTable.selectAll(false);
                hostCollectionsPane.refresh();
                $scope.host.$get();
                deferred.resolve(response);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                $scope.errorMessages = response.data.errors;
                $scope.hostCollectionsTable.working = false;
            };

            $scope.hostCollectionsTable.working = true;
            hostCollections = _.pluck(host['host_collections'], 'id');
            hostCollectionsToRemove = _.pluck($scope.hostCollectionsTable.getSelected(), 'id');

            data = {"host_collection_ids": _.difference(hostCollections, hostCollectionsToRemove)};
            Host.updateHostCollections({id: host.id}, data, success, error);

            return deferred.promise;
        };
    }]
);
