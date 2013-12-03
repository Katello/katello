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
 * @name  Bastion.content-views.controller:ContentViewAvailableProductsController
 *
 * @requires $scope
 * @requires ContentView
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewAvailableProductsController',
    ['$scope', 'ContentView',
    function($scope, ContentView) {

        $scope.repositories = (function() {
            var repositories = [
                {
                    product: {name: 'test', id: 1},
                    id: '1',
                    name: 'Repo Name 87',
                    content_type: 'test'
                },
                {
                    product: {name: 'test2', id: 2},
                    id: '2',
                    name: 'Repo Name 55',
                    content_type: 'test'
                },
                {
                    product: {name: 'test', id: 1},
                    id: '3',
                    name: 'Repo Name 66',
                    content_type: 'test'
                },
                {
                    product: {name: 'test3', id: 3},
                    id: '4',
                    name: 'Repo Name 32',
                    content_type: 'test'
                }],
                find = function(repository) {
                    var found = false;

                    angular.forEach($scope.contentView.repositories, function(addedRepository) {
                        if (repository.id === addedRepository.id) {
                            found = repository;
                        }
                    });

                    return found;
                },
                available = [];


            angular.forEach(repositories, function(repository) {
                var found = find(repository);

                if (!found) {
                    available.push(repository);
                }
            });

            return available;
        })();

        $scope.products = extractProducts();

        $scope.repositoryFilter = function(repository) {
            if ($scope.product !== undefined && $scope.product !== null) {
                if (repository.product.id === $scope.product.id) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return true;
            }
        };

        $scope.addRepositories = function() {
            var kept = [];

            angular.forEach($scope.repositories, function(repository) {
                if (!repository.selected) {
                    repository.selected = false;
                    kept.push(repository);
                } else {
                    $scope.contentView.repositories.push(repository);
                }
            });

            $scope.repositories = kept;
        };

        $scope.selectAll = function(selected) {
            angular.forEach($scope.repositories, function(repository) {
                repository.selected = selected;
            });
        };

        function extractProducts() {
            var products = {};

            angular.forEach($scope.repositories, function(repository) {
                products[repository.product.id] = repository.product;
            });

            return products;
        }

    }]
);
