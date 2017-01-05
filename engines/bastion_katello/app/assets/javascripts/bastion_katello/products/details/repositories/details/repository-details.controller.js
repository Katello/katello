(function () {
    function RepositoryDetailsController($scope, $state, translate, Repository, Product, ApiErrorHandler) {
        /**
         * @ngdoc object
         * @name  Bastion.repositories.controller:RepositoryDetailsController
         *
         * @requires $scope
         * @requires $state
         * @requires translate
         * @requires Repository
         * @requires ApiErrorHandler
         *
         * @description
         *   Core functionality for Repository.
         */

        var errorHandler = function errorHandler(response) {
            $scope.errorMessages = response.data.errors;
        };

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.page = {
            error: false,
            loading: true
        };

        if ($scope.repository) {
            $scope.page.loading = false;
        }

        $scope.product = Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.page.loading = false;
        }, function (response) {
            $scope.page.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.repository = Repository.get({
            'product_id': $scope.$stateParams.productId,
            'id': $scope.$stateParams.repositoryId
        }, function () {
            $scope.page.loading = false;
        }, function (response) {
            $scope.page.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.syncRepository = function (repository) {
            Repository.sync({id: repository.id}, function (task) {
                $state.go('product.repository.tasks.details', {taskId: task.id});
            }, errorHandler);
        };

        $scope.republishRepository = function (repository) {
            Repository.republish({id: repository.id}, function (task) {
                $state.go('product.repository.tasks.details', {taskId: task.id});
            }, errorHandler);
        };

        $scope.syncInProgress = function (task) {
            var inProgress = false;
            if (task && (task.state === 'pending' || task.state === 'running')) {
                inProgress = true;
            }
            return inProgress;
        };

        $scope.removeRepository = function (repository) {
            var success, repositoryName = repository.name;

            success = function () {
                $scope.transitionTo('product.repositories', {productId: $scope.$stateParams.productId});
                $scope.$parent.successMessages = [translate('Repository "%s" successfully deleted').replace('%s', repositoryName)];
            };

            repository.$delete(success, errorHandler);
        };

        $scope.canRemove = function (repo, product) {
            return $scope.getRepoNonDeletableReason(repo, product) === null;
        };

        $scope.getRepoNonDeletableReason = function (repo, product) {
            var readOnlyReason = null;

            if (repo.$resolved && product.$resolved) {
                if ($scope.denied('destroy_products', product)) {
                    readOnlyReason = 'permissions';
                } else if (repo.promoted) {
                    readOnlyReason = 'published';
                } else if (repo['product_type'] === "redhat") {
                    readOnlyReason = 'redhat';
                }
            }
            return readOnlyReason;
        };
    }

    angular.module('Bastion.repositories').controller('RepositoryDetailsController', RepositoryDetailsController);

    RepositoryDetailsController.$inject = ['$scope', '$state', 'translate', 'Repository', 'Product', 'ApiErrorHandler'];
})();
