/**
 * @ngdoc object
 * @name  Bastion.systems.controller:ActivationKeyHostCollectionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires ActivationKey
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the list host collections details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'ActivationKey', 'Nutupane',
    function ($scope, $q, $location, translate, ActivationKey, Nutupane) {
        var hostCollectionsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'id': $scope.$stateParams.activationKeyId,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'full_result': true
        };

        hostCollectionsPane = new Nutupane(ActivationKey, params, 'hostCollections');
        $scope.table = hostCollectionsPane.table;

        $scope.removeHostCollections = function () {
            var data,
                success,
                error,
                deferred = $q.defer(),
                hostCollectionsToRemove = _.map($scope.table.getSelected(), 'id');

            data = {
                "activation_key": {
                    "host_collection_ids": hostCollectionsToRemove
                }
            };

            success = function (response) {
                $scope.successMessages = [translate('Removed %x host collections from activation key "%y".')
                    .replace('%x', $scope.table.numSelected)
                    .replace('%y', $scope.activationKey.name)];
                $scope.table.working = false;
                $scope.table.selectAll(false);
                hostCollectionsPane.refresh();
                $scope.activationKey.$get();
                deferred.resolve(response);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                $scope.errorMessages = response.data.errors;
                $scope.table.working = false;
            };

            $scope.table.working = true;
            ActivationKey.removeHostCollections({id: $scope.activationKey.id}, data, success, error);
            return deferred.promise;
        };
    }]
);
