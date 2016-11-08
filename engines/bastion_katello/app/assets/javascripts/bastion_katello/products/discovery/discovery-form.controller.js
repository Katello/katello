/**
 * @ngdoc object
 * @name  Bastion.products.controller:DiscoveryFormController
 *
 * @requires $scope
 * @requires $q
 * @requires CurrentOrganization
 * @requires Product
 * @requires Repository
 * @requires FormUtils
 *
 * @description
 *   Provides the functionality for the repo creation as part of
 *      repository discovery.
 */
angular.module('Bastion.products').controller('DiscoveryFormController',
    ['$scope', '$q', 'CurrentOrganization', 'Product', 'Repository', 'GPGKey', 'FormUtils',
    function ($scope, $q, CurrentOrganization, Product, Repository, GPGKey, FormUtils) {

        function productCreateError(response) {
            $scope.working = false;
            $scope.createRepoChoices.creating = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.productForm[field].$setValidity('server', false);
                $scope.productForm[field].$error.messages = errors;
            });
        }

        function repoCreateError(response) {
            var currentlyCreating = $scope.currentlyCreating;
            $scope.currentlyCreating = undefined;
            $scope.createRepoChoices.creating = false;
            currentlyCreating.form.$invalid = true;
            currentlyCreating.form.messages = response.data.errors;
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

        function getNextRepoToCreate() {
            var found;
            angular.forEach($scope.discovery.selected, function (repo) {
                if (repo.created !== true && angular.isUndefined(found)) {
                    found = repo;
                }
            });
            return found;
        }

        function createNextRepo() {
            var toCreate, repoObject;
            toCreate = getNextRepoToCreate();

            if (toCreate) {
                $scope.currentlyCreating = toCreate;
                repoObject = convertToResource(toCreate);
                toCreate.creating = true;
                toCreate.form.$invalid = false;

                repoObject.$save(function () {
                    toCreate.creating = false;
                    toCreate.created = true;
                    createNextRepo();
                }, repoCreateError);
            } else {
                $scope.transitionTo('product.repositories', {productId: $scope.createRepoChoices.existingProductId});
            }
        }

        function productCreateSuccess(response) {
            $scope.createRepoChoices.existingProductId = response.id;
            $scope.createRepoChoices.newProduct = 'false';
            $scope.products.unshift(response);
            createNextRepo();
        }

        $scope.discovery = $scope.discovery || {selected: []};
        $scope.page = {loading: true};
        $scope.$watch('createRepoChoices.product.name', function () {
            FormUtils.labelize($scope.createRepoChoices.product);
        });

        $scope.createRepoChoices = {
            existingProductId: undefined,
            newProduct: 'false',
            product: new Product(),
            unprotected: true,
            creating: false
        };

        $scope.createRepoChoices.product['organization_id'] = CurrentOrganization;

        angular.forEach($scope.discovery.selected, function (repo) {
            //Add a fake form to keep track of validations
            repo.form = {
                    messages: '',
                    $invalid: false
                };
            FormUtils.labelize(repo);
        });

        Product.queryUnpaged({'organization_id': CurrentOrganization, custom: true}, function (values) {
            $scope.products = values.results;

            if ($scope.products.length > 0) {
                $scope.createRepoChoices.existingProductId = $scope.products[0].id;
            } else {
                $scope.createRepoChoices.newProduct = "true";
            }
            $scope.page.loading = false;
        });

        $scope.creating = function () {
            return $scope.createRepoChoices.creating;
        };

        $scope.requiredFieldsEnabled = function () {
            var fieldsEnabled = true;
            if ($scope.createRepoChoices.newProduct === "true") {
                fieldsEnabled = $scope.productForm.$valid;
            } else if (angular.isUndefined($scope.createRepoChoices.existingProductId)) {
                fieldsEnabled = false;
            }

            if (fieldsEnabled) {
                return $scope.productForm.$valid;
            }

            return fieldsEnabled;
        };

        $scope.gpgKeys = GPGKey.queryUnpaged();

        $scope.$watch('discovery.selected', function (newList, oldList) {
            if (newList) {
                angular.forEach(newList, function (newItem, position) {
                    if (angular.isUndefined(oldList) || newItem.name !== oldList[position].name) {
                        FormUtils.labelize(newItem);
                    }
                });
            }
        }, function (newList, oldList) {
            var isEqual = true;
            angular.forEach(newList, function (newItem, position) {
                if (newList[position].name !== oldList[position].name) {
                    isEqual = false;
                }
            });
            return isEqual;
        });

        $scope.createRepos = function () {
            $scope.createRepoChoices.creating = true;

            if ($scope.createRepoChoices.newProduct === "true") {
                Product.save($scope.createRepoChoices.product, productCreateSuccess, productCreateError);
            } else {
                createNextRepo();
            }
        };

    }]
);
