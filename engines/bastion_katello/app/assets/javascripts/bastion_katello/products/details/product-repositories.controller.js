/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductRepositoriesController
 *
 * @requires $scope
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
    ['$scope', '$state', 'Repository', 'RepositoryBulkAction', 'CurrentOrganization', 'Nutupane', 'translate',
    function ($scope, $state, Repository, RepositoryBulkAction, CurrentOrganization, Nutupane, translate) {
        var repositoriesNutupane = new Nutupane(Repository, {
            'product_id': $scope.$stateParams.productId,
            'library': true,
            'organization_id': CurrentOrganization,
            'enabled': true,
            'full_result': true
        });
        repositoriesNutupane.masterOnly = true;

        function getParams() {
            return {
                ids: repositoriesNutupane.getAllSelectedResults('id').included.ids
            };
        }

        $scope.close = function(index) {
            $scope.removingTasks.splice(index, 1);
        };

        function success(response) {
            angular.forEach(response.task.input.target_ids, function (row) {
                $scope.detailsTable.removeRow(row);
            });
            $scope.removingTasks.push(response.task.id);
        }

        function error(response) {
            $scope.errorMessages = response.data.errors;
        }

        $scope.removingTasks = [];
        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.checksums = [{name: translate('Default'), id: null}, {id: 'sha256', name: 'sha256'}, {id: 'sha1', name: 'sha1'}];
        $scope.detailsTable = repositoriesNutupane.table;
        $scope.detailsTable.removeRow = repositoriesNutupane.removeRow;
        repositoriesNutupane.query();

        $scope.syncSelectedRepositories = function () {
            var params = getParams();

            RepositoryBulkAction.syncRepositories(params, function (task) {
                $state.go('products.details.tasks.details', {taskId: task.id});
            },
            function (response) {
                $scope.errorMessages = response.data.errors;
            });
        };

        $scope.removeSelectedRepositories = function () {
            var params = getParams(), removalPromise;

            $scope.removingRepositories = true;
            removalPromise = RepositoryBulkAction.removeRepositories(params, success, error).$promise;

            removalPromise.finally(function () {
                $scope.removingRepositories = false;
            });
        };

        $scope.removeRepository = function (repository) {
            repositoriesNutupane.removeRow(repository.id);
            repository.$delete(function () {
                $scope.transitionTo('products.details.repositories.index', {productId: $scope.$stateParams.productId});
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
