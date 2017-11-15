/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:NewRepositoryController
 *
 * @requires $scope
 * @requires Repository
 * @requires Product
 * @requires ContentCredential
 * @requires FormUtils
 * @requires translate
 * @requires Notification
 * @requires ApiErrorHandler
 * @requires BastionConfig
 * @requires Checksum
 * @requires DownloadPolicy
 * @requires OstreeUpstreamSyncPolicy
 * @requires Architecture
 *
 * @description
 *   Controls the creation of an empty Repository object for use by sub-controllers.
 */
angular.module('Bastion.repositories').controller('NewRepositoryController',
    ['$scope', 'Repository', 'Product', 'ContentCredential', 'FormUtils', 'translate', 'Notification', 'ApiErrorHandler', 'BastionConfig', 'Checksum', 'DownloadPolicy', 'OstreeUpstreamSyncPolicy', 'Architecture',
    function ($scope, Repository, Product, ContentCredential, FormUtils, translate, Notification, ApiErrorHandler, BastionConfig, Checksum, DownloadPolicy, OstreeUpstreamSyncPolicy, Architecture) {

        function success() {
            Notification.setSuccessMessage(translate('Repository %s successfully created.').replace('%s', $scope.repository.name));
            $scope.transitionTo('product.repositories', {productId: $scope.$stateParams.productId});
        }

        function error(response) {
            var foundError = false;
            $scope.working = false;

            angular.forEach($scope.repositoryForm, function (field) {
                if ($scope.repositoryForm.hasOwnProperty(field) && field.hasOwnProperty('$modelValue')) {
                    field.$setValidity('server', true);
                    $scope.repositoryForm[field].$error.messages = [];
                }
            });

            angular.forEach(response.data.errors, function (errors, field) {
                if ($scope.repositoryForm.hasOwnProperty(field)) {
                    foundError = true;
                    $scope.repositoryForm[field].$setValidity('server', false);
                    $scope.repositoryForm[field].$error.messages = errors;
                }
            });

            if (!foundError) {
                Notification.setErrorMessage(response.data.displayMessage);
            }
        }

        $scope.page = {
            error: false,
            loading: true
        };

        $scope.repository = new Repository({'product_id': $scope.$stateParams.productId, unprotected: true,
            'checksum_type': null, 'mirror_on_sync': true, 'verify_ssl_on_sync': true,
            'download_policy': BastionConfig.defaultDownloadPolicy, 'arch': null,
            'ostree_upstream_sync_policy': 'latest'});

        $scope.product = Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.page.loading = false;
        }, function (response) {
            $scope.page.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        Repository.repositoryTypes({'creatable': true}, function (data) {
            $scope.repositoryTypes = data;
        });

        $scope.checksums = Checksum.checksums;
        $scope.downloadPolicies = DownloadPolicy.downloadPolicies;
        $scope.ostreeUpstreamSyncPolicies = OstreeUpstreamSyncPolicy.syncPolicies;

        $scope.$watch('repository.name', function () {
            if ($scope.repositoryForm && $scope.repositoryForm.name) {
                $scope.repositoryForm.name.$setValidity('server', true);
                FormUtils.labelize($scope.repository);
            }
        });

        ContentCredential.queryUnpaged(function (contentCredentials) {
            $scope.contentCredentials = contentCredentials.results;
        });

        Architecture.queryUnpaged(function (architecture) {
            var results = architecture.results;
            var noarch = {
                id: 'noarch',
                name: translate('Default'),
                value: null
            };
            results.map(function(i) {
                i.id = i.name;
            });
            results.unshift(noarch);
            $scope.architecture = results;
            $scope.repository.arch = results[0].id;
        });

        $scope.save = function (repository) {
            if (repository.content_type === 'ostree') {
                repository.unprotected = false;
            }
            if (repository.content_type !== 'yum') {
                repository['download_policy'] = '';
            }
            if (repository.arch === 'Default') {
                repository.arch = null;
            }
            repository.$save(success, error);
        };

    }]
);
