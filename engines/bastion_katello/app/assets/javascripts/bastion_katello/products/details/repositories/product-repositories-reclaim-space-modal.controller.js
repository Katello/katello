/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:ProductRepositoriesReclaimSpaceModalController
 *
 * @requires $scope
 * @requires $state
 * @requires translate
 * @requires Notification
 * @requires RepositoryBulkAction
 * @requires $uibModalInstance
 * @requires reclaimParams
 *
 * @description
 *   A controller for the modal that warns about reclaiming on demand repository space
 */
angular.module('Bastion.repositories').controller('ProductRepositoriesReclaimSpaceModalController',
    ['$scope', '$state', 'translate', 'Notification', 'RepositoryBulkAction', '$uibModalInstance', 'reclaimParams',
        function ($scope, $state, translate, Notification, RepositoryBulkAction, $uibModalInstance, reclaimParams) {
            $scope.ok = function () {
                RepositoryBulkAction.reclaimSpaceFromRepositories(reclaimParams, function (task) {
                    $state.go('product.tasks.details', {taskId: task.id});
                },
                function (response) {
                    angular.forEach(response.data.errors, function (error) {
                        Notification.setErrorMessage(error);
                    });
                });
                $uibModalInstance.close();
            };

            $scope.cancel = function () {
                $uibModalInstance.dismiss('cancel');
            };
        }]
);
