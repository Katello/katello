(function () {
    function RepositoryDetailsController($scope, $state, translate, Repository, Product, ApiErrorHandler, Notification) {
        /**
         * @ngdoc object
         * @name  Bastion.repositories.controller:RepositoryDetailsController
         *
         * @requires $scope
         * @requires $state
         * @requires translate
         * @requires Repository
         * @requires ApiErrorHandler
         * @requires Notification
         *
         * @description
         *   Core functionality for Repository.
         */

        var errorHandler = function errorHandler(response) {
            angular.forEach(response.data.errors, function (error) {
                Notification.setErrorMessage(error);
            });
        };

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
            if (!_.isEmpty($scope.repository["docker_tags_whitelist"])) {
                $scope.repository.commaTagsWhitelist = $scope.repository["docker_tags_whitelist"].join(", ");
            } else {
                $scope.repository.commaTagsWhitelist = "";
            }
            $scope.page.loading = false;
        }, function (response) {
            $scope.page.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.hideSyncButton = function(repository, advancedSync) {
            var result = $scope.syncInProgress(repository.last_sync) || !repository.url || $scope.denied('sync_products', $scope.product);
            if (advancedSync) {
                result = result || repository.content_type !== 'yum';
            }
            return result;
        };

        $scope.disableSyncLink = function (adavancedSync) {
            return $scope.hideSyncButton($scope.repository, adavancedSync);
        };

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
                Notification.setSuccessMessage(translate('Repository "%s" successfully deleted').replace('%s', repositoryName));
            };

            repository.$delete(success, errorHandler);
        };

        $scope.canRemove = function (repo, product) {
            return $scope.getRepoNonDeletableReason(repo, product) === null;
        };

        $scope.getRepoNonDeletableReason = function (repo, product) {
            var readOnlyReason = null;

            if (repo.$resolved && product.$resolved) {
                if (repo.promoted) {
                    readOnlyReason = 'published';
                } else if (repo['product_type'] === "redhat") {
                    readOnlyReason = 'redhat';
                } else if ($scope.denied('deletable', repo)) {
                    readOnlyReason = 'permissions';
                }
            }
            return readOnlyReason;
        };
    }

    angular.module('Bastion.repositories').controller('RepositoryDetailsController', RepositoryDetailsController);

    RepositoryDetailsController.$inject = ['$scope', '$state', 'translate', 'Repository', 'Product', 'ApiErrorHandler', 'Notification'];
})();
