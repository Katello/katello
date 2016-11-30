/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductRepositoriesController
 *
 * @requires $scope
 * @requires $location
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
    ['$scope', '$state', '$location', 'ApiErrorHandler', 'Product', 'Repository', 'RepositoryBulkAction', 'CurrentOrganization', 'Nutupane', 'translate',
    function ($scope, $state, $location, ApiErrorHandler, Product, Repository, RepositoryBulkAction, CurrentOrganization, Nutupane, translate) {
        var repositoriesNutupane = new Nutupane(Repository, {
            'product_id': $scope.$stateParams.productId,
            'search': $location.search().search || "",
            'library': true,
            'organization_id': CurrentOrganization,
            'enabled': true,
            'paged': true
        });
        repositoriesNutupane.masterOnly = true;

        function getParams() {
            return {
                ids: repositoriesNutupane.getAllSelectedResults('id').included.ids
            };
        }

        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.page = $scope.page || {loading: false};

        $scope.product = Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.page.loading = false;
        }, function (response) {
            $scope.page.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.close = function(index) {
            $scope.removingTasks.splice(index, 1);
        };


        $scope.removingTasks = [];

        $scope.checksums = [{name: translate('Default'), id: null}, {id: 'sha256', name: 'sha256'}, {id: 'sha1', name: 'sha1'}];
        $scope.table = repositoriesNutupane.table;

        $scope.syncSelectedRepositories = function () {
            var params = getParams();

            RepositoryBulkAction.syncRepositories(params, function (task) {
                $state.go('product.tasks.details', {taskId: task.id});
            },
            function (response) {
                $scope.errorMessages = response.data.errors;
            });
        };

        $scope.removeSelectedRepositories = function () {
            var success, error, params = getParams(), removalPromise;

            success = function (response) {
                $scope.removingTasks.push(response.task.id);
            };

            error = function (response) {
                $scope.errorMessages = response.data.errors;
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
