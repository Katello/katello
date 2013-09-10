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
 * @requires Product
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Bastion.products').controller('DiscoveryFormController',
    ['$scope', '$q', '$http', 'CurrentOrganization', 'Provider', 'Product', 'Repository',
    function($scope, $q, $http, CurrentOrganization, Provider, Product, Repository) {
        var fetchProviders, fetchProducts, filterEditable;

        angular.forEach($scope.discovery.selected, function(repo) {
            //Add a fake form to keep track of validations
            repo.form = {
                    messages: '',
                    $invalid: false
            };
            fetchRepoLabel(repo);
        });

        fetchProviders = function() {
            var deferred = $q.defer();
            Provider.query({paged: false}, function(providers) {
                deferred.resolve(providers.results);
            });
            return deferred.promise;
        };

        fetchProducts = function() {
            var deferred = $q.defer();
            Product.query({paged: false, 'organization_id': CurrentOrganization}, function(products) {
                deferred.resolve(products.results);
            });
            return deferred.promise;
        };

        filterEditable = function(items){
            var toRet = [];
            angular.forEach(items, function(value){
               if (!value.readonly) {
                toRet.push(value);
               }
            });
            return toRet;
        };

        //Start new repo stuff
        $scope.$watch('createRepoChoices.product.name', function() {
            $http({
                method: 'GET',
                url: '/katello/organizations/default_label',
                params: {'name': $scope.createRepoChoices.product.name}
            })
            .success(function(response) {
                $scope.createRepoChoices.product.label = response;
            })
            .error(function(response) {
                $scope.productForm.label.$setValidity('', false);
                $scope.productForm.label.$error.messages = response.errors;
            });
        });

        $scope.transitionToDiscovery = function() {
            $scope.transitionTo('products.discovery.scan');
        };

        $scope.creating = function(){
            return $scope.createRepoChoices.creating;
        };

        function fetchRepoLabel(repo) {
            $http({
                method: 'GET',
                url: '/katello/organizations/default_label',
                params: {'name': repo.name}
            })
            .success(function(response) {
                repo.label = response;
            });
        }

        $scope.$watch('discovery.selected', function(newList, oldList) {
            if (newList) {
                angular.forEach(newList, function(newItem, position){
                    if (oldList === undefined || newItem.name !== oldList[position].name) {
                        fetchRepoLabel(newItem);
                    }
                });
            }
        }, function(newList, oldList) {
            var isEqual = true;
            angular.forEach(newList, function(newItem, position){
                if (newList[position].name !== oldList[position].name) {
                    isEqual = false;
                }
            });
            return isEqual;
        });

        $scope.createRepoChoices = {
          existingProductId: undefined,
          newProduct: 'false',
          product : new Product(),
          unprotected: true,
          creating: false
        };

        fetchProviders().then(function(values){
            $scope.providers = filterEditable(values);
            if ($scope.providers[0]) {
                $scope.createRepoChoices.product['provider_id'] = $scope.providers[0].id;
            }
        });

        fetchProducts().then(function(values) {
            $scope.products = filterEditable(values);
            if ($scope.products[0]) {
                $scope.createRepoChoices.existingProductId = $scope.products[0].id;
            }
        });

        $scope.createRepos = function(){
            $scope.createRepoChoices.creating = true;

            if ($scope.createRepoChoices.newProduct === "true") {
                new Product($scope.createRepoChoices.product).$save(function(data){
                    $scope.createRepoChoices.existingProductId = data.id;
                    $scope.createRepoChoices.newProduct = 'false';
                    $scope.products.unshift(data);
                    //add it to the main products table
                    $scope.table.addRow(data);
                    createNextRepo();
                }, productCreateError);
            }
            else {
                createNextRepo();
            }
        };

        function createNextRepo(){
            var toCreate, repoObject;
            toCreate = getNextRepoToCreate();
            if (toCreate) {
                $scope.currentlyCreating = toCreate;
                repoObject = convertToResource(toCreate);
                toCreate.creating = true;
                toCreate.form.$invalid = false;

                repoObject.$save(function(){
                    toCreate.creating = false;
                    toCreate.created = true;
                    createNextRepo();
                }, repoCreateError);
            }
            else {
                $scope.transitionTo('products.details.repositories.index',
                    {productId: $scope.createRepoChoices.existingProductId});
            }
        }

        function getNextRepoToCreate(){
            var found;
            angular.forEach($scope.discovery.selected, function(repo){
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

        function productCreateError(response) {
            $scope.createRepoChoices.creating = false;
            $scope.productForm.$setDirty();
            angular.forEach(response.data.errors, function(errors, field) {
                $scope.productForm[field].$setValidity('', false);
                $scope.productForm[field].messages = errors;
            });
        }

    }]
);
