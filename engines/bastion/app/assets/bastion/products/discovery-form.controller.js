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
 * @name  Bastion.products.controller:DiscoveryFormController
 *
 * @requires $scope
 * @requires $http
 * @requires CurrentOrganization
 * @requires Provider
 * @requires Product
 * @requires Repository
 *
 * @description
 *   Provides the functionality for the repo creation as part of
 *      repository discovery.
 */
angular.module('Bastion.products').controller('DiscoveryFormController',
    ['$scope', '$http', 'CurrentOrganization', 'Provider', 'Product', 'Repository',
    function($scope, $http, CurrentOrganization, Provider, Product, Repository) {

        $scope.discovery = $scope.discovery || {selected: []};
        $scope.panel = $scope.panel || {loading: false};

        $scope.createRepoChoices = {
          existingProductId: undefined,
          newProduct: 'false',
          product : new Product(),
          unprotected: true,
          creating: false
        };

        angular.forEach($scope.discovery.selected, function(repo) {
            //Add a fake form to keep track of validations
            repo.form = {
                    messages: '',
                    $invalid: false
            };
            fetchRepoLabel(repo);
        });

        Provider.query(function(values) {
            $scope.providers = filterEditable(values.results);

            if ($scope.providers.length > 0) {
                $scope.createRepoChoices.product['provider_id'] = $scope.providers[0].id;
            }
        });

        Product.query({'organization_id': CurrentOrganization}, function(values) {
            $scope.products = filterEditable(values.results);

            if ($scope.products.length > 0) {
                $scope.createRepoChoices.existingProductId = $scope.products[0].id;
            }
        });

        $scope.$watch('createRepoChoices.product.name', function() {
            $http({
                method: 'GET',
                url: '/katello/organizations/default_label',
                params: {'name': $scope.createRepoChoices.product.name}
            })
            .success(function(response) {
                $scope.createRepoChoices.product.label = response;
                $scope.panel.loading = false;
            })
            .error(function(response) {
                $scope.productForm.label.$setValidity('', false);
                $scope.productForm.label.$error.messages = response.errors;
            });
        });

        $scope.transitionToDiscovery = function() {
            $scope.transitionTo('products.discovery.scan');
        };

        $scope.creating = function() {
            return $scope.createRepoChoices.creating;
        };

        $scope.$watch('discovery.selected', function(newList, oldList) {
            if (newList) {
                angular.forEach(newList, function(newItem, position) {
                    if (oldList === undefined || newItem.name !== oldList[position].name) {
                        fetchRepoLabel(newItem);
                    }
                });
            }
        }, function(newList, oldList) {
            var isEqual = true;
            angular.forEach(newList, function(newItem, position) {
                if (newList[position].name !== oldList[position].name) {
                    isEqual = false;
                }
            });
            return isEqual;
        });

        $scope.createRepos = function() {
            $scope.createRepoChoices.creating = true;

            if ($scope.createRepoChoices.newProduct === "true") {
                Product.save($scope.createRepoChoices.product, productCreateSuccess, productCreateError);
            } else {
                createNextRepo();
            }
        };

        function productCreateSuccess(response) {
            $scope.createRepoChoices.existingProductId = response.id;
            $scope.createRepoChoices.newProduct = 'false';
            $scope.products.unshift(response);
            //add it to the main products table
            $scope.table.addRow(response);
            createNextRepo();
        }

        function productCreateError(response) {
            $scope.createRepoChoices.creating = false;
            $scope.productForm.$setDirty();
            angular.forEach(response.data.errors, function(errors, field) {
                $scope.productForm[field].$setValidity('', false);
                $scope.productForm[field].messages = errors;
            });
        }

        function fetchRepoLabel(repo) {
            $http({
                method: 'GET',
                url: '/katello/organizations/default_label',
                params: {'name': repo.name}
            })
            .success(function(response) {
                repo.label = response;
            }).error(function(response) {
                repo.form.$invalid = true;
                repo.form.messages = response.errors;
            });
        }

        function createNextRepo() {
            var toCreate, repoObject;
            toCreate = getNextRepoToCreate();

            if (toCreate) {
                $scope.currentlyCreating = toCreate;
                repoObject = convertToResource(toCreate);
                toCreate.creating = true;
                toCreate.form.$invalid = false;

                repoObject.$save(function() {
                    toCreate.creating = false;
                    toCreate.created = true;
                    createNextRepo();
                }, repoCreateError);
            } else {
                $scope.transitionTo('products.details.repositories.index',
                    {productId: $scope.createRepoChoices.existingProductId});
            }
        }

        function getNextRepoToCreate() {
            var found;
            angular.forEach($scope.discovery.selected, function(repo) {
                if (repo.created !== true && found === undefined) {
                    found = repo;
                }
            });
            return found;
        }

        function convertToResource(repo) {
            return new Repository({
                name: repo.name,
                label: repo.label,
                'content_type': 'yum',
                url: repo.url,
                'product_id': $scope.createRepoChoices.existingProductId,
                unprotected: $scope.createRepoChoices.unprotected
            });
        }

        function repoCreateError(response) {
            var currentlyCreating = $scope.currentlyCreating;
            $scope.currentlyCreating = undefined;
            $scope.createRepoChoices.creating = false;

            currentlyCreating.form.$invalid = true;
            currentlyCreating.form.messages = response.data.errors;
        }

        function filterEditable(items) {
            return _.where(items, {readonly: false});
        }

    }]
);
