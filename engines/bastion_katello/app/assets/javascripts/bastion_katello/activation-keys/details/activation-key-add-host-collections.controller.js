/**
 * @ngdoc object
 * @name  Bastion.systems.controller:ActivationKeyAddHostCollectionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires ActivationKey
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for adding host collections to an activation key.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyAddHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'ActivationKey', 'Nutupane',
    function ($scope, $q, $location, translate, ActivationKey, Nutupane) {
        var hostCollectionsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'full_result': true,
            'id': $scope.$stateParams.activationKeyId
        };

        hostCollectionsPane = new Nutupane(ActivationKey, params, 'availableHostCollections');
        $scope.hostCollectionsTable = hostCollectionsPane.table;

        $scope.addHostCollections = function () {
            var data,
                success,
                error,
                deferred = $q.defer(),
                hostCollectionsToAdd = _.pluck($scope.hostCollectionsTable.getSelected(), 'id');

            data = {
                "activation_key": {
                    "host_collection_ids": hostCollectionsToAdd
                }
            };

            success = function (response) {
                $scope.successMessages = [translate('Added %x host collections to activation key "%y".')
                    .replace('%x', $scope.hostCollectionsTable.numSelected)
                    .replace('%y', $scope.activationKey.name)];
                $scope.hostCollectionsTable.working = false;
                $scope.hostCollectionsTable.selectAll(false);
                hostCollectionsPane.refresh();
                $scope.activationKey.$get();
                deferred.resolve(response);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                $scope.errorMessages = response.data.errors.base;
                $scope.hostCollectionsTable.working = false;
            };

            $scope.hostCollectionsTable.working = true;
            ActivationKey.addHostCollections({id: $scope.activationKey.id}, data, success, error);
            return deferred.promise;
        };
    }]
);
