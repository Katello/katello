(function () {
    'use strict';

    /**
     * @ngdoc service
     * @name  Bastion.common.service:ApiErrorHandler
     *
     * @description
     *   Provides common functionality in handling Katello/Foreman API Errors.
     */
    function ApiErrorHandler(translate, GlobalNotification) {
        function handleError(response, $scope, defaultErrorMessage) {
            var hasScopeErrorMessages = $scope && $scope.hasOwnProperty('errorMessages');

            if (response.hasOwnProperty('data') && response.data.hasOwnProperty('errors')) {
                if (hasScopeErrorMessages) {
                    $scope.errorMessages = response.data.errors;
                } else {
                    angular.forEach(response.data.errors, function (error) {
                        GlobalNotification.setErrorMessage(error);
                    });
                }
            } else {
                if (hasScopeErrorMessages) {
                    $scope.errorMessages = [defaultErrorMessage];
                } else {
                    GlobalNotification.setErrorMessage(defaultErrorMessage);
                }
            }

            if ($scope && $scope.hasOwnProperty('panel')) {
                $scope.panel.error = true;
            }
        }

        this.handleGETRequestErrors = function (response, $scope) {
            var defaultErrorMessage = translate('Something went wrong when retrieving the resource.');
            handleError(response, $scope, defaultErrorMessage);
        };

        this.handlePUTRequestErrors = function (response, $scope) {
            var defaultErrorMessage = translate('Something went wrong when saving the resource.');
            handleError(response, $scope, defaultErrorMessage);
        };
    }

    angular.module('Bastion.common').service('ApiErrorHandler', ApiErrorHandler);
    ApiErrorHandler.$inject = ['translate', 'GlobalNotification'];
})();
