/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductRepositoriesController
 *
 * @requires $scope
 * @requires $location
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
    ['$scope', '$state', '$location', 'Notification', 'translate', 'ApiErrorHandler', 'Product', 'Repository', 'RepositoryBulkAction', 'CurrentOrganization', 'Nutupane',
    function ($scope, $state, $location, Notification, translate, ApiErrorHandler, Product, Repository, RepositoryBulkAction, CurrentOrganization, Nutupane) {
        var repositoriesNutupane = new Nutupane(Repository, {
            'product_id': $scope.$stateParams.productId,
            'search': $location.search().search || "",
            'library': true,
            'organization_id': CurrentOrganization,
            'enabled': true,
            'paged': true
        });
        $scope.controllerName = 'katello_repositories';
        repositoriesNutupane.masterOnly = true;

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
                var message = translate('Removal of selected repositories initiated successfully.');
                var link = ("/foreman_tasks/tasks/%taskId").replace('%taskId', response.task.id);
                var alertBody = { children: translate("Click to view task"), href: link };
                Notification.setSuccessMessage(message, {link: alertBody});
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
                } else if (product.redhat) {
                    readOnlyReason = 'redhat';
                }
            }

            return readOnlyReason;
        };

        $scope.canRemoveRepositories = function (product) {
            return $scope.getRepositoriesNonDeletableReason(product) === null;
        };
    }]
);
