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
        this.handleGETRequestErrors = function (response, $scope) {
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
                    $scope.errorMessages = [translate('Something went wrong when retrieving the resource.')];
                } else {
                    GlobalNotification.setErrorMessage(translate('Something went wrong when retrieving the resource.'));
                }
            }

            if ($scope && $scope.hasOwnProperty('panel')) {
                $scope.panel.error = true;
            }
        };
    }

    angular.module('Bastion.common').service('ApiErrorHandler', ApiErrorHandler);

    ApiErrorHandler.$inject = ['translate', 'GlobalNotification'];

})();
