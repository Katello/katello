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
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for adding host collections to a content host.
 */
angular.module('Bastion.content-hosts').controller('ContentHostAddHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'HostCollection', 'Host', 'Nutupane',
    function ($scope, $q, $location, translate, HostCollection, Host, Nutupane) {
        var params, hostCollectionsPane;

        params = {
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true,
            'available_for': 'host'
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

        $scope.addHostCollections = function (contentHost) {
            var deferred = $q.defer(),
                success,
                error,
                data,
                hostCollections,
                hostCollectionsToAdd;

            success = function (response) {
                $scope.successMessages = [translate('Added %x host collections to content host "%y".')
                    .replace('%x', $scope.hostCollectionsTable.numSelected).replace('%y', $scope.contentHost.name)];
                $scope.hostCollectionsTable.working = false;
                $scope.hostCollectionsTable.selectAll(false);
                hostCollectionsPane.refresh();
                $scope.contentHost.$get();
                deferred.resolve(response);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                $scope.errorMessages = response.data.errors.base;
                $scope.hostCollectionsTable.working = false;
            };

            $scope.hostCollectionsTable.working = true;

            hostCollections = _.pluck($scope.contentHost.hostCollections, 'id');
            hostCollectionsToAdd = _.pluck($scope.hostCollectionsTable.getSelected(), 'id');
            data = {"host_collection_ids": _.union(hostCollections, hostCollectionsToAdd)};

            Host.updateHostCollections({id: contentHost.host.id}, data, success, error);

            return deferred.promise;
        };
    }]
);
