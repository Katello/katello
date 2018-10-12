(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.environments.controller:EnvironmentController
     *
     * @description
     *   Enter a description!
     */
    function EnvironmentController($scope, Environment, translate, ContentService, ApiErrorHandler, Notification, RepositoryTypesService) {

        $scope.contentTypes = ContentService.contentTypes;
        $scope.panel = {
            error: false,
            loading: true
        };

        $scope.repositoryTypeEnabled = RepositoryTypesService.repositoryTypeEnabled;
        $scope.environment = Environment.get({id: $scope.$stateParams.environmentId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.save = function (environment) {
            var promise;

            function success() {
                Notification.setSuccessMessage(translate('Environment saved'));
            }

            function error(response) {
                angular.forEach(response.data.errors, function (errorMessage) {
                    Notification.setErrorMessage((translate("An error occurred saving the Environment: ") + errorMessage));
                });
            }

            promise = environment.$update();
            promise.then(success, error);

            return promise;
        };

        $scope.remove = function (environment) {
            var promise;

            function success() {
                Notification.setSuccessMessage(translate('Remove Successful.'));
                $scope.transitionTo('environments');
            }

            function error(response) {
                Notification.setErrorMessage(translate("An error occurred removing the environment: ") +
                    response.data.displayMessage);
            }

            promise = environment.$delete();
            promise.then(success, error);

            return promise;
        };

    }

    angular
        .module('Bastion.environments')
        .controller('EnvironmentController', EnvironmentController);

    EnvironmentController.$inject = ['$scope', 'Environment', 'translate', 'ContentService', 'ApiErrorHandler', 'Notification', 'RepositoryTypesService'];

})();
