/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:NewRepositoryController
 *
 * @requires $scope
 * @requires Repository
 * @requires Product
 * @requires GPGKey
 * @requires FormUtils
 * @requires translate
 * @requires GlobalNotification
 * @requires ApiErrorHandler
 * @requires BastionConfig
 *
 * @description
 *   Controls the creation of an empty Repository object for use by sub-controllers.
 */
angular.module('Bastion.repositories').controller('NewRepositoryController',
    ['$scope', 'Repository', 'Product', 'GPGKey', 'FormUtils', 'translate', 'GlobalNotification', 'ApiErrorHandler', 'BastionConfig',
    function ($scope, Repository, Product, GPGKey, FormUtils, translate, GlobalNotification, ApiErrorHandler, BastionConfig) {

        function success() {
            GlobalNotification.setSuccessMessage(translate('Repository %s successfully created.').replace('%s', $scope.repository.name));
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
                GlobalNotification.setErrorMessage(response.data.displayMessage);
            }
        }

        $scope.page = {
            error: false,
            loading: true
        };

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.repository = new Repository({'product_id': $scope.$stateParams.productId, unprotected: true,
            'checksum_type': null, 'mirror_on_sync': true, 'verify_ssl_on_sync': true,
            'download_policy': BastionConfig.defaultDownloadPolicy});

        $scope.product = Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.page.loading = false;
        }, function (response) {
            $scope.page.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        Repository.repositoryTypes({'creatable': true}, function (data) {
            $scope.repositoryTypes = data;
        });

        $scope.$watch('repository.name', function () {
            if ($scope.repositoryForm && $scope.repositoryForm.name) {
                $scope.repositoryForm.name.$setValidity('server', true);
                FormUtils.labelize($scope.repository);
            }
        });

        GPGKey.queryUnpaged(function (gpgKeys) {
            $scope.gpgKeys = gpgKeys.results;
        });

        $scope.save = function (repository) {
            if (repository.content_type === 'ostree') {
                repository.unprotected = false;
            }
            if (repository.content_type !== 'yum') {
                repository['download_policy'] = '';
            }
            repository.$save(success, error);
        };

    }]
);
