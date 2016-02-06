/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionHostCollectionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires HostBulkAction
 * @requires HostCollection
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'Nutupane', 'HostBulkAction', 'HostCollection', 'CurrentOrganization',
    function ($scope, $q, $location, translate, Nutupane, HostBulkAction, HostCollection, CurrentOrganization) {
        var hostCollectionNutupane, nutupaneParams;

        $scope.hostCollections = {
            action: null
        };
        $scope.setState(false, [], []);

        nutupaneParams = {
            'organization_id': CurrentOrganization,
            'offset': 0,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        hostCollectionNutupane = new Nutupane(HostCollection, nutupaneParams, 'queryPaged');

        $scope.setState(false, [], []);
        $scope.detailsTable = hostCollectionNutupane.table;
        $scope.detailsTable.closeItem = function () {};

        $scope.confirmHostCollectionAction = function (action) {
            $scope.hostCollections.confirm = true;
            $scope.hostCollections.action = action;
        };

        $scope.performHostCollectionAction = function () {
            var params, action, success, error, deferred = $q.defer();

            action = $scope.hostCollections.action;
            params = $scope.nutupane.getAllSelectedResults('id');
            params['organization_id'] = CurrentOrganization;
            params['host_collection_ids'] = hostCollectionNutupane.getAllSelectedResults('id').included.ids;

            $scope.hostCollections.action = null;
            $scope.setState(true, [], []);

            success = function (data) {
                deferred.resolve(data);
                $scope.setState(false, data.displayMessages.success, data.displayMessages.error);
                hostCollectionNutupane.refresh();
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                $scope.setState(false, [], [response.data.displayMessage]);
                $scope.editMode = true;
            };

            if (action === 'add') {
                HostBulkAction.addHostCollections(params, success, error);
            } else if (action === 'remove') {
                HostBulkAction.removeHostCollections(params, success, error);
            }

            return deferred.promise;
        };

    }]
);
