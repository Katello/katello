(function () {
    'use strict';

    /**
     * @ngdoc service
     * @name  Bastion.common.service:ApiErrorHandler
     *
     * @description
     *   Provides common functionality in handling Katello/Foreman API Errors.
     */
    function ApiErrorHandler(translate, Notification) {
        function handleError(response, $scope, defaultErrorMessage) {
            if (response.hasOwnProperty('data') && response.data.hasOwnProperty('errors')) {
                angular.forEach(response.data.errors, function (error) {
                    Notification.setErrorMessage(error);
                });
            } else {
                Notification.setErrorMessage(defaultErrorMessage);
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

        this.handleDELETERequestErrors = function (response, $scope) {
            var defaultErrorMessage = translate('Something went wrong when deleting the resource.');
            handleError(response, $scope, defaultErrorMessage);
        };
    }

    angular.module('Bastion.common').service('ApiErrorHandler', ApiErrorHandler);
    ApiErrorHandler.$inject = ['translate', 'Notification'];
})();
