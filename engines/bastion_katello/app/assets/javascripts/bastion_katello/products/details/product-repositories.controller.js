/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductRepositoriesController
 *
 * @requires $scope
 * @requires $location
 * @requires $uibModal
 * @requires Notification
 * @requires translate
 * @requires ApiErrorHandler
 * @requires Product
 * @requires Repository
 * @requires RepositoryBulkAction
 * @requires CurrentOrganization
 * @requires Nutupane
 *
 *
 * @description
 *   Provides the functionality for manipulating repositories attached to a product.
 */
angular.module('Bastion.products').controller('ProductRepositoriesController',
    ['$scope', '$state', '$location', '$uibModal', 'Notification', 'translate', 'ApiErrorHandler', 'Product', 'Repository', 'RepositoryBulkAction', 'CurrentOrganization', 'Nutupane', 'RepositoryTypesService',
    function ($scope, $state, $location, $uibModal, Notification, translate, ApiErrorHandler, Product, Repository, RepositoryBulkAction, CurrentOrganization, Nutupane, RepositoryTypesService) {
        var repositoriesNutupane = new Nutupane(Repository, {
            'product_id': $scope.$stateParams.productId,
            'search': $location.search().search || "",
            'library': true,
            'organization_id': CurrentOrganization,
            'enabled': true,
            'paged': true
        });
        $scope.controllerName = 'katello_repositories';
        repositoriesNutupane.primaryOnly = true;

        function getParams() {
            return {
                ids: repositoriesNutupane.getAllSelectedResults('id').included.ids
            };
        }

        $scope.page = $scope.page || {loading: false};

        $scope.product = Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.page.loading = false;
        }, function (response) {
            $scope.page.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.table = repositoriesNutupane.table;

        $scope.syncSelectedRepositories = function () {
            var params = getParams();

            RepositoryBulkAction.syncRepositories(params, function (task) {
                $state.go('product.tasks.details', {taskId: task.id});
            },
            function (response) {
                angular.forEach(response.data.errors, function (error) {
                    Notification.setErrorMessage(error);
                });
            });
        };

        $scope.removeSelectedRepositories = function () {
            var success, error, params = getParams(), removalPromise;

            success = function (response) {
                $state.go('product.tasks.details', {taskId: response.task.id});
            };

            error = function (response) {
                angular.forEach(response.data.errors, function (errorMessage) {
                    Notification.setErrorMessage(errorMessage);
                });
            };

            $scope.removingRepositories = true;
            removalPromise = RepositoryBulkAction.removeRepositories(params, success, error).$promise;

            removalPromise.finally(function () {
                $scope.removingRepositories = false;
            });
        };

        $scope.openReclaimSpaceModal = function () {
            $uibModal.open({
                templateUrl: 'products/details/repositories/views/product-repositories-reclaim-space-modal.html',
                controller: 'ProductRepositoriesReclaimSpaceModalController',
                size: 'lg',
                resolve: {
                    reclaimParams: getParams()
                }
            });
        };

        $scope.genericContentTypesFor = function(contentTypeLabel) {
            return RepositoryTypesService.genericContentTypes(contentTypeLabel);
        };

        $scope.removeRepository = function (repository) {
            repository.$delete(function () {
                $scope.transitionTo('product.repositories', {productId: $scope.$stateParams.productId});
            });
        };

        $scope.getRepositoriesNonDeletableReason = function (product) {
            var readOnlyReason = null;

            if (product.$resolved) {
                if ($scope.denied('destroy_products', product)) {
                    readOnlyReason = 'permissions';
                }
            }

            return readOnlyReason;
        };

        $scope.canRemoveRepositories = function (product) {
            return $scope.getRepositoriesNonDeletableReason(product) === null;
        };
    }]
);
