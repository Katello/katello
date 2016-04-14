/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:NewRepositoryController
 *
 * @requires $scope
 * @requires Repository
 * @requires GPGKey
 * @requires FormUtils
 * @requires translate
 *
 * @description
 *   Controls the creation of an empty Repository object for use by sub-controllers.
 */
angular.module('Bastion.repositories').controller('NewRepositoryController',
    ['$scope', 'Repository', 'GPGKey', 'FormUtils', 'translate', 'GlobalNotification', 'BastionConfig', 'Setting', 'ApiErrorHandler',
    function ($scope, Repository, GPGKey, FormUtils, translate, GlobalNotification, BastionConfig, Setting, ApiErrorHandler) {

        function success(response) {
            $scope.detailsTable.rows.push(response);
            GlobalNotification.setSuccessMessage(translate('Repository %s successfully created.').replace('%s', $scope.repository.name));
            $scope.transitionTo('products.details.repositories.index', {productId: $scope.$stateParams.productId});
        }

        function error(response) {
            var foundError = false;
            $scope.working = false;

            angular.forEach($scope.repositoryForm, function (value, field) {
                if ($scope.repositoryForm.hasOwnProperty(field) && value.hasOwnProperty('$setValidity')) {
                    value.$setValidity('server', true);
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

        Setting.get({"search": "name = enable_deferred_download_policies"},
        function (data) {
            data = angular.fromJson(data);
            $scope.enableDownloadPolicies = data.results[0].value;
        }, function (data) {
            ApiErrorHandler.handleGETRequestErrors(data, $scope);
        });

        $scope.repository = new Repository({'product_id': $scope.$stateParams.productId, unprotected: true,
            'checksum_type': null, 'download_policy': null, 'mirror_on_sync': true});

        Repository.repositoryTypes({'creatable': true}, function (data) {
            $scope.repositoryTypes = data;
        });

        $scope.$watch('repository.name', function () {
            if ($scope.repositoryForm.name) {
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
            repository.$save(success, error);
        };

    }]
);
