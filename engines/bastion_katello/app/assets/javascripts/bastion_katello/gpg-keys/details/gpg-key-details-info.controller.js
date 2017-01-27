/**
 * @ngdoc object
 * @name  Bastion.gpgKeys.controller:GPGKeyDetailsInfoController
 *
 * @requires $scope
 * @requires GPGKey
 * @requires translate
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the gpgKey details action pane.
 */
angular.module('Bastion.gpg-keys').controller('GPGKeyDetailsInfoController',
    ['$scope', 'GPGKey', 'translate', 'Notification', function ($scope, GPGKey, translate, Notification) {

        $scope.panel = $scope.panel || {loading: false};
        $scope.progress = {uploading: false};

        $scope.gpgKey = $scope.gpgKey || GPGKey.get({id: $scope.$stateParams.gpgKeyId}, function () {
            $scope.panel.loading = false;
        });

        $scope.gpgKey.$promise.then(function () {
            $scope.uploadURL = '/katello/api/v2/gpg_keys/' + $scope.gpgKey.id + '/content';
        });

        $scope.uploadContent = function (content) {
            if (content && (content !== "Please wait...")) {
                if (content.status === 'success') {
                    Notification.setSuccessMessage(translate('GPG Key successfully uploaded'));
                    $scope.uploadStatus = 'success';
                    $scope.gpgKey.$get();
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
