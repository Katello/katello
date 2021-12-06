/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:RepositoryDetailsReclaimSpaceModalController
 *
 * @requires $scope
 * @requires $state
 * @requires translate
 * @requires Notification
 * @requires Repository
 * @requires $uibModalInstance
 * @requires reclaimParams
 *
 * @description
 *   A controller for the modal that warns about reclaiming on demand repository space
 */
angular.module('Bastion.repositories').controller('RepositoryDetailsReclaimSpaceModalController',
    ['$scope', '$state', 'translate', 'Notification', 'Repository', '$uibModalInstance', 'reclaimParams',
        function ($scope, $state, translate, Notification, Repository, $uibModalInstance, reclaimParams) {
            var errorHandler = function errorHandler(response) {
                angular.forEach(response.data.errors, function (error) {
                    Notification.setErrorMessage(error);
                });
            };

            $scope.ok = function () {
                Repository.reclaimSpace({id: reclaimParams.repository.id}, function (task) {
                    $state.go('product.repository.tasks.details', {taskId: task.id});
                }, errorHandler);
                $uibModalInstance.close();
            };

            $scope.cancel = function () {
                $uibModalInstance.dismiss('cancel');
            };
        }]
);
