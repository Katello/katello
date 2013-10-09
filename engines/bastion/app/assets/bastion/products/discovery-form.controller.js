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
 * @requires $q
 * @requires CurrentOrganization
 * @requires Provider
 * @requires Product
 * @requires Repository
 * @requires FormUtils
 *
 * @description
 *   Provides the functionality for the repo creation as part of
 *      repository discovery.
 */
angular.module('Bastion.products').controller('DiscoveryFormController',
    ['$scope', '$q', 'CurrentOrganization', 'Provider', 'Product', 'Repository', 'GPGKey', 'FormUtils',
    function($scope, $q, CurrentOrganization, Provider, Product, Repository, GPGKey, FormUtils) {

        $scope.discovery = $scope.discovery || {selected: []};
        $scope.panel = $scope.panel || {loading: false};

        $scope.$watch('createRepoChoices.product.name', function() {
            FormUtils.labelize($scope.createRepoChoices.product, $scope.productForm);
        });

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
            FormUtils.labelize(repo, repo.form);
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
            } else {
                $scope.createRepoChoices.newProduct = "true";
            }
            $scope.panel.loading = false;
        });

        $scope.transitionToDiscovery = function() {
            $scope.transitionTo('products.discovery.scan');
        };

        $scope.creating = function() {
            return $scope.createRepoChoices.creating;
        };

        $scope.gpgKeys = GPGKey.query();

        $scope.$watch('discovery.selected', function(newList, oldList) {
            if (newList) {
                angular.forEach(newList, function(newItem, position) {
                    if (oldList === undefined || newItem.name !== oldList[position].name) {
                        FormUtils.labelize(newItem, newItem.form);
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
