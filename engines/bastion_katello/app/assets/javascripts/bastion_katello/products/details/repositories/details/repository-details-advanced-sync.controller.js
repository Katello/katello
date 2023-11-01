/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:RepositoryAdvancedSyncController
 *
 * @requires $scope
 * @requires $state
 * @requires Notification
 * @requires Repository
 * @requires translate
 *
 * @description
 *   Provides the functionality for advanced repository syncing
 */
angular.module('Bastion.repositories').controller('RepositoryAdvancedSyncController',
    ['$scope', '$state', 'Notification', 'Repository', 'translate',
    function ($scope, $state, Notification, Repository, translate) {
        var errorHandler = function errorHandler(response) {
            angular.forEach(response.data.errors, function (error) {
                Notification.setErrorMessage(error);
            });
            $scope.working = false;
        };

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Advanced Sync');

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
