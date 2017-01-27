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
 * @requires Notification
 *
 * @description
 *   Provides the functionality for adding host collections to an activation key.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyAddHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'ActivationKey', 'Nutupane', 'Notification',
    function ($scope, $q, $location, translate, ActivationKey, Nutupane, Notification) {
        var hostCollectionsPane, params;

        params = {
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'full_result': true,
            'id': $scope.$stateParams.activationKeyId
        };

        hostCollectionsPane = new Nutupane(ActivationKey, params, 'availableHostCollections');
        $scope.controllerName = 'katello_host_collections';
        $scope.table = hostCollectionsPane.table;

        $scope.addHostCollections = function () {
            var data,
                success,
                error,
                deferred = $q.defer(),
                hostCollectionsToAdd = _.map($scope.table.getSelected(), 'id');

            data = {
                "activation_key": {
                    "host_collection_ids": hostCollectionsToAdd
                }
            };

            success = function (response) {
                var message = translate('Added %x host collections to activation key "%y".')
                    .replace('%x', $scope.table.numSelected)
                    .replace('%y', $scope.activationKey.name);

                Notification.setSuccessMessage(message);
                $scope.table.working = false;
                $scope.table.selectAll(false);
                hostCollectionsPane.refresh();
                $scope.activationKey.$get();
                deferred.resolve(response);
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                Notification.setErrorMessage(response.data.errors.base);
                $scope.table.working = false;
            };

            $scope.table.working = true;
            ActivationKey.addHostCollections({id: $scope.activationKey.id}, data, success, error);
            return deferred.promise;
        };
    }]
);
