/**
 * @ngdoc object
 * @name  Bastion.contentCredentials.controller:ContentCredentialDetailsInfoController
 *
 * @requires $scope
 * @requires ContentCredential
 * @requires translate
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the contentCredential details action pane.
 */
angular.module('Bastion.content-credentials').controller('ContentCredentialDetailsInfoController',
    ['$scope', 'ContentCredential', 'translate', 'Notification', function ($scope, ContentCredential, translate, Notification) {

        $scope.panel = $scope.panel || {loading: false};
        $scope.progress = {uploading: false};

        $scope.contentCredential = $scope.contentCredential || ContentCredential.get({id: $scope.$stateParams.contentCredentialId}, function () {
            $scope.panel.loading = false;
        });

        $scope.contentCredential.$promise.then(function () {
            $scope.uploadURL = 'katello/api/v2/content_credentials/' + $scope.contentCredential.id + '/content';
        });

        $scope.uploadContent = function (content) {
            if (content && (content !== "Please wait...")) {
                if (content.status === 'success') {
                    Notification.setSuccessMessage(translate('Content Credential successfully uploaded'));
                    $scope.uploadStatus = 'success';
                    $scope.contentCredential.$get();
                } else {
                    Notification.setErrorMessage(content.displayMessage);
                    $scope.uploadStatus = 'error';
                }

                $scope.progress.uploading = false;
            }
        };

        $scope.uploadError = function (error, content) {
            if (angular.isString(content) && content.indexOf("Request Entity Too Large")) {
                error = translate('File too large.');
            } else {
                error = content;
            }
            Notification.setErrorMessage(translate('Error during upload: ') + error);
            $scope.uploadStatus = 'error';
            $scope.progress.uploading = false;
        };

    }]
);
