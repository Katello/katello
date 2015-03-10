/**
 * Copyright 2014 Red Hat, Inc.
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
    ['$scope', '$state', 'Repository', 'RepositoryBulkAction', 'CurrentOrganization', 'Nutupane', 'translate',
    function ($scope, $state, Repository, RepositoryBulkAction, CurrentOrganization, Nutupane, translate) {
        var repositoriesNutupane = new Nutupane(Repository, {
            'product_id': $scope.$stateParams.productId,
            'library': true,
            'organization_id': CurrentOrganization,
            'enabled': true,
            'full_result': true
        });

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.checksums = [{name: translate('Default'), id: null}, {id: 'sha256', name: 'sha256'}, {id: 'sha1', name: 'sha1'}];
        $scope.repositoriesTable = repositoriesNutupane.table;
        $scope.repositoriesTable.removeRow = repositoriesNutupane.removeRow;
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
            var params = getParams(), removalPromise, removeSuccess;

            removeSuccess = function (response) {
                if (response.errors && response.errors.length > 0) {
                    $scope.warningMessages = response.errors;
                    $scope.warningTaskId = response.task.id;
                } else {
                    $state.go('products.details.tasks.details', {taskId: response.task.id});
                }
            };

            $scope.removingRepositories = true;
            removalPromise = RepositoryBulkAction.removeRepositories(params, removeSuccess, error).$promise;

            removalPromise["finally"](function () {
                repositoriesNutupane.refresh();
                $scope.removingRepositories = false;
            });
        };

        $scope.getRepositoriesNonDeletableReason = function (product) {
            var readOnlyReason = null;

            if (product.$resolved) {
                if ($scope.denied('delete_products', product)) {
                    readOnlyReason = 'permissions';
                }  else if (product.redhat) {
                    readOnlyReason = 'redhat';
                }
            }

            return readOnlyReason;
        };

        $scope.canRemoveRepositories = function (product) {
            return $scope.getRepositoriesNonDeletableReason(product) === null;
        };

        function getParams() {
            return {
                ids: repositoriesNutupane.getAllSelectedResults('id').included.ids
            };
        }

        function error(response) {
            $scope.errorMessages = response.data.errors;
        }
    }]
);
