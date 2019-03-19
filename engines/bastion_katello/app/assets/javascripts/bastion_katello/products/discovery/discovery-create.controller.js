/**
 * @ngdoc object
 * @name  Bastion.products.controller:DiscoveryCreateController
 *
 * @requires $scope
 * @requires $q
 * @requires Notification
 * @requires CurrentOrganization
 * @requires Product
 * @requires Repository
 * @requires ContentCredential
 * @requires FormUtils
 * @requires DiscoveryRepositories
 * @requires translate
 *
 * @description
 *   Provides the functionality for the repo creation as part of
 *      repository discovery.
 */
angular.module('Bastion.products').controller('DiscoveryCreateController',
    ['$scope', '$q', 'Notification', 'CurrentOrganization', 'Product', 'Repository', 'ContentCredential', 'FormUtils', 'DiscoveryRepositories', 'translate', 'ApiErrorHandler',
    function ($scope, $q, Notification, CurrentOrganization, Product, Repository, ContentCredential, FormUtils, DiscoveryRepositories, translate, ApiErrorHandler) {

        $scope.table = {
            rows: DiscoveryRepositories.getRows(),
            resource: {
                total: DiscoveryRepositories.getRows().length,
                subtotal: DiscoveryRepositories.getRows().length
            }
        };

        function convertToResource(repo) {
            var repoParams = {
                'docker_upstream_name': repo.dockerUpstreamName,
                name: repo.name,
                label: repo.label,
                'content_type': repo.contentType,
                'product_id': $scope.createRepoChoices.existingProductId,
                unprotected: $scope.createRepoChoices.unprotected,
                'verify_ssl': $scope.createRepoChoices.verifySsl,
                'upstream_username': $scope.createRepoChoices.upstreamUsername,
                'upstream_password': $scope.createRepoChoices.upstreamPassword
            };

            repoParams.url = $scope.getRepoPath(repo);

            if (repo.contentType === 'docker') {
                repoParams.url = $scope.createRepoChoices.repositoryUrl;
            }

            return new Repository(repoParams);
        }

        function getNextRepoToCreate() {
            var found;
            angular.forEach($scope.table.rows, function (repo) {
                if (angular.isUndefined(found) && repo.created !== true && repo.form.$invalid !== true) {
                    found = repo;
                }
            });
            return found;
        }

        function repoCreateError(response) {
            var currentlyCreating = $scope.currentlyCreating;
            $scope.currentlyCreating = undefined;
            currentlyCreating.messages = response.data.displayMessage;
            currentlyCreating.creating = false;
            currentlyCreating.form.$invalid = true;
        }

        function createNextRepo() {
            var toCreate, repoObject;
            toCreate = getNextRepoToCreate();

            if (toCreate) {
                toCreate.messages = translate("Creating repository...");
                $scope.currentlyCreating = toCreate;
                repoObject = convertToResource(toCreate);
                toCreate.creating = true;
                toCreate.form.$invalid = false;

                repoObject.$save(function (task) {
                    toCreate.creating = false;
                    toCreate.created = true;
                    toCreate.messages = translate("Success!");
                    toCreate.repositoryId = task.id;
                    toCreate.productId = task.product.id;
                    createNextRepo();
                }, function(response) {
                    repoCreateError(response);
                    createNextRepo();
                });
            } else {
                $scope.createRepoChoices.creating = false;
            }
        }

        function productCreateError(response) {
            $scope.createRepoChoices.creating = false;
            angular.forEach(response.data.errors, function (errors, field) {
                Notification.setErrorMessage(translate('An error occurred while creating the Product: %s').replace('%s', field + ' ' + errors));
                if (!angular.isUndefined($scope.productForm[field])) {
                    $scope.productForm[field].$error.messages = errors;
                }
            });
        }

        function productCreateSuccess(response) {
            $scope.createRepoChoices.existingProductId = response.id;
            $scope.createRepoChoices.newProduct = 'false';
            $scope.products.unshift(response);
            createNextRepo();
        }

        $scope.page = {loading: true};
        $scope.$watch('createRepoChoices.product.name', function () {
            FormUtils.labelize($scope.createRepoChoices.product);
        });

        $scope.createRepoChoices = {
            existingProductId: undefined,
            newProduct: 'false',
            product: new Product(),
            unprotected: true,
            creating: false,
            verifySsl: true,
            repositoryUrl: DiscoveryRepositories.getRepositoryUrl(),
            upstreamUsername: DiscoveryRepositories.getUpstreamUsername(),
            upstreamPassword: DiscoveryRepositories.getUpstreamPassword()
        };

        $scope.getRepoPath = function (repo) {
            return repo.repositoryUrl;
        };

        $scope.createRepoChoices.product['organization_id'] = CurrentOrganization;

        angular.forEach($scope.table.rows, function (repo) {
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

        $scope.contentCredentials = [];
        ContentCredential.queryUnpaged(function (contentCredentials) {
            $scope.contentCredentials = contentCredentials.results;
        }, function (response) {
            $scope.contentCredentials = [];
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.$watch('table.rows', function (newList, oldList) {
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

        $scope.clearInvalidRepos = function () {
            angular.forEach($scope.table.rows, function (repo) {
                repo.form.$invalid = false;
            });
        };

        $scope.createRepos = function () {
            $scope.createRepoChoices.creating = true;
            $scope.clearInvalidRepos();

            if ($scope.createRepoChoices.newProduct === "true") {
                Product.save($scope.createRepoChoices.product, productCreateSuccess, productCreateError);
            } else {
                createNextRepo();
            }
        };

        $scope.createStatusIcon = function (repo) {
            var icon;
            if (repo.created === true) {
                icon = 'pficon pficon-ok';
            } else if (repo.creating === true) {
                icon = 'fa fa-spinner fa-spin';
            } else if (angular.isUndefined(repo.messages)) {
                icon = '';
            } else {
                icon = 'pficon pficon-error-circle-o';
            }

            return icon;
        };

        $scope.createStatusMessages = function (repo) {
            var message;
            if (angular.isUndefined(repo.messages)) {
                message = translate("Not started");
            } else {
                message = repo.messages;
            }
            return message;
        };
    }]
);
