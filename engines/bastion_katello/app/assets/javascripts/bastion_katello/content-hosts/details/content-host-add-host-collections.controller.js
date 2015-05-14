/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostAddHostCollectionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires ContentHost
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for adding host collections to a content host.
 */
angular.module('Bastion.content-hosts').controller('ContentHostAddHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'ContentHost', 'Nutupane',
    function ($scope, $q, $location, translate, ContentHost, Nutupane) {
        var hostCollectionsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true,
            'id': $scope.$stateParams.contentHostId
        };

        hostCollectionsPane = new Nutupane(ContentHost, params, 'availableHostCollections');
        $scope.hostCollectionsTable = hostCollectionsPane.table;

        $scope.addHostCollections = function (contentHost) {
            var deferred = $q.defer(),
                success,
                error,
                hostCollections,
                hostCollectionsToAdd;

            success = function (data) {
                $scope.successMessages = [translate('Added %x host collections to content host "%y".')
                    .replace('%x', $scope.hostCollectionsTable.numSelected).replace('%y', $scope.contentHost.name)];
                $scope.hostCollectionsTable.working = false;
                $scope.hostCollectionsTable.selectAll(false);
                hostCollectionsPane.refresh();
                $scope.contentHost.$get();
                deferred.resolve(data);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                $scope.errorMessages = response.data.errors.base;
                $scope.hostCollectionsTable.working = false;
            };

            $scope.hostCollectionsTable.working = true;

            hostCollections = _.pluck($scope.contentHost.hostCollections, 'id');
            hostCollectionsToAdd = _.pluck($scope.hostCollectionsTable.getSelected(), 'id');
            contentHost["host_collection_ids"] = _.union(hostCollections, hostCollectionsToAdd);

            contentHost.$update({id: $scope.contentHost.uuid}, success, error);
            return deferred.promise;
        };
    }]
);
