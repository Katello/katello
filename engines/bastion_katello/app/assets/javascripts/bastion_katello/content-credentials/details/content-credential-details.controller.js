/**
 * @ngdoc object
 * @name  Bastion.content-credentials.controller:ContentCredentialDetailsController
 *
 * @requires $scope
 * @requires ContentCredential
 * @requires $q
 * @requires translate
 * @requires ApiErrorHandler
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the contentCredential details action pane.
 */
angular.module('Bastion.content-credentials').controller('ContentCredentialDetailsController',
    ['$scope', 'ContentCredential', '$q', 'translate', 'ApiErrorHandler', 'Notification', function ($scope, ContentCredential, $q, translate, ApiErrorHandler, Notification) {
        $scope.panel = $scope.panel || {error: false, loading: false};

        $scope.contentCredential = ContentCredential.get({id: $scope.$stateParams.contentCredentialId}, function () {
            $scope.panel.error = false;
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.save = function (contentCredential) {
            var deferred = $q.defer();

            contentCredential.$update(function (response) {
                deferred.resolve(response);
                Notification.setSuccessMessage(translate('Content credential updated'));

            }, function (response) {
                deferred.reject(response);
                Notification.setErrorMessage(response.data.displayMessage);
            });

            return deferred.promise;
        };

        $scope.removeContentCredential = function (contentCredential) {
            contentCredential.$delete(function () {
                $scope.transitionTo('content-credentials');
            });
        };
    }]
);
