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
            'paged': true
        };

        hostCollectionsPane = new Nutupane(HostCollection, params);
        hostCollectionsPane.table.initialLoad = false;
        $scope.hostCollectionsTable = hostCollectionsPane.table;

        $scope.contentHost.$promise.then(function(contentHost) {
            params['host_id'] = contentHost.host.id;
            hostCollectionsPane.setParams(params);
            hostCollectionsPane.load(true);
        });

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.removeHostCollections = function (contentHost) {
            var deferred = $q.defer(),
                success,
                error,
                data,
                hostCollections,
                hostCollectionsToRemove;

            success = function (response) {
                $scope.successMessages = [translate('Removed %x host collections from content host "%y".')
                    .replace('%x', $scope.hostCollectionsTable.numSelected).replace('%y', $scope.contentHost.name)];
                $scope.hostCollectionsTable.working = false;
                $scope.hostCollectionsTable.selectAll(false);
                hostCollectionsPane.refresh();
                $scope.contentHost.$get();
                deferred.resolve(response);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                $scope.errorMessages = response.data.errors;
                $scope.hostCollectionsTable.working = false;
            };

            $scope.hostCollectionsTable.working = true;

            hostCollections = _.pluck($scope.contentHost.hostCollections, 'id');
            hostCollectionsToRemove = _.pluck($scope.hostCollectionsTable.getSelected(), 'id');
            data = {"host_collection_ids": _.difference(hostCollections, hostCollectionsToRemove)};

            Host.updateHostCollections({id: contentHost.host.id}, data, success, error);

            return deferred.promise;
        };
    }]
);
