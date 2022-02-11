(function () {
    function RepositoryDetailsController($scope, $state, $uibModal, translate, Repository, Product, ApiErrorHandler, Notification) {
        /**
         * @ngdoc object
         * @name  Bastion.repositories.controller:RepositoryDetailsController
         *
         * @requires $scope
         * @requires $state
         * @requires $uibModal
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

        $scope.repositoryVersions = function () {
            return _.groupBy($scope.repository.content_view_versions, function(version) {
                return version.content_view_id;
            });
        };

        $scope.repositoryWrapper = {
            repository: $scope.repository,
            repositoryVersions: {}
        };

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
            if (!_.isEmpty($scope.repository["include_tags"])) {
                $scope.repository.commaIncludeTags = $scope.repository["include_tags"].join(", ");
            } else {
                $scope.repository.commaIncludeTags = "";
            }
            if (!_.isEmpty($scope.repository["exclude_tags"])) {
                $scope.repository.commaExcludeTags = $scope.repository["exclude_tags"].join(", ");
            } else {
                $scope.repository.commaExcludeTags = "";
            }
            $scope.page.loading = false;
            $scope.repositoryWrapper.repository = $scope.repository;
            $scope.repositoryWrapper.repositoryVersions = $scope.repositoryVersions();
        }, function (response) {
            $scope.page.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.hideSyncButton = function(repository, advancedSync) {
            var result = $scope.syncInProgress(repository.last_sync) || !repository.url || $scope.denied('sync_products', $scope.product);
            if (advancedSync) {
                result = result || (repository.content_type !== 'yum' && repository.content_type !== 'deb');
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

        $scope.verifyChecksum = function (repository) {
            Repository.verifyChecksum({id: repository.id}, function (task) {
                $state.go('product.repository.tasks.details', {taskId: task.id});
            }, errorHandler);
        };

        $scope.openReclaimSpaceModal = function (repository) {
            $uibModal.open({
                templateUrl: 'products/details/repositories/details/views/repository-details-reclaim-space-modal.html',
                controller: 'RepositoryDetailsReclaimSpaceModalController',
                size: 'lg',
                resolve: {
                    reclaimParams: function() {
                        return { repository: repository };
                    }
                }
            });
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

            Repository.remove({id: repository.id}, success, errorHandler);
        };

        $scope.canRemove = function (repo, product) {
            return $scope.getRepoNonDeletableReason(repo, product) === null;
        };

        $scope.getRepoNonDeletableReason = function (repo, product) {
            var readOnlyReason = null;

            if (repo.$resolved && product.$resolved) {
                if ($scope.denied('deletable', repo)) {
                    readOnlyReason = 'permissions';
                }
            }
            return readOnlyReason;
        };
    }

    angular.module('Bastion.repositories').controller('RepositoryDetailsController', RepositoryDetailsController);

    RepositoryDetailsController.$inject = ['$scope', '$state', '$uibModal', 'translate', 'Repository', 'Product', 'ApiErrorHandler', 'Notification'];
})();
