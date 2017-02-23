/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:RepositoryAdvancedSyncController
 *
 * @requires $scope
 * @requires $state
 * @requires Repository
 *
 * @description
 *   Provides the functionality for advanced repository syncing
 */
angular.module('Bastion.repositories').controller('RepositoryAdvancedSyncController',
    ['$scope', '$state', 'Repository',
    function ($scope, $state, Repository) {
        var errorHandler = function errorHandler(response) {
            $scope.errorMessages = response.data.errors;
            $scope.working = false;
        };

        $scope.advancedSync = function (syncType) {
            var params = {id: $scope.repository.id};
            if (syncType === "skipMetadataCheck") {
                params['skip_metadata_check'] = true;
            } else if (syncType === "validateContents") {
                params['validate_contents'] = true;
            }

            Repository.sync(params, function (task) {
                $state.go('product.repository.tasks.details', {taskId: task.id});
            }, errorHandler);
        };
    }]
);
