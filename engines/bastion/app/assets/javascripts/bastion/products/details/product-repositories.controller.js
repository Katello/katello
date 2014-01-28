/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

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
    ['$scope', 'Repository', 'RepositoryBulkAction', 'CurrentOrganization', 'Nutupane',
    function ($scope, Repository, RepositoryBulkAction, CurrentOrganization, Nutupane) {
        var repositoriesNutupane = new Nutupane(Repository, {
            'product_id': $scope.$stateParams.productId,
            'library': true,
            'organization_id': CurrentOrganization,
            'enabled': true
        });

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.repositoriesTable = repositoriesNutupane.table;
        repositoriesNutupane.query();

        $scope.syncSelectedRepositories = function () {
            var params = getParams();

            $scope.syncInProgress = true;
            RepositoryBulkAction.syncRepositories(params, success, error).$promise.then(function () {
                repositoriesNutupane.refresh();
                $scope.syncInProgress = false;
            });
        };

        $scope.removeSelectedRepositories = function () {
            var params = getParams();

            $scope.removingRepositories = true;
            RepositoryBulkAction.removeRepositories(params, success, error).$promise.then(function () {
                repositoriesNutupane.refresh();
                $scope.removingRepositories = false;
            });
        };

        $scope.removeRepository = function (repository) {
            repositoriesNutupane.removeRow(repository.id);
            repository.$delete(function () {
                $scope.transitionTo('products.details.repositories.index', {productId: $scope.$stateParams.productId});
            });
        };

        function getParams() {
            return {
                ids: repositoriesNutupane.getAllSelectedResults('id').included.ids
            };
        }

        function success(response) {
            $scope.successMessages = response.displayMessages;
        }

        function error(response) {
            $scope.successMessages = response.data.errors;
        }
    }]
);
