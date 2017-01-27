/**
 * @ngdoc object
 * @name  Bastion.gpg-keys.controller:NewGPGKeyController
 *
 * @requires $scope
 * @requires $state
 * @requires translate
 * @requires GPGKey
 * @requires CurrentOrganization
 * @requires Notification
 *
 * @description
 *   Controls the creation of an empty GPGKey object for use by sub-controllers.
 */
angular.module('Bastion.gpg-keys').controller('NewGPGKeyController',
    ['$scope', '$state', 'translate', 'GPGKey', 'CurrentOrganization', 'Notification',
    function ($scope, $state, translate, GPGKey, CurrentOrganization, Notification) {
        $scope.panel = {loading: false};
        $scope.gpgKey = new GPGKey();
        $scope.CurrentOrganization = CurrentOrganization;
        $scope.progress = {uploading: false};
        $scope.uploadURL = '/katello/api/v2/gpg_keys?organization_id=' + CurrentOrganization;

        $scope.uploadContent = function (response) {
            if (response) {
                if (angular.isUndefined(response.errors)) {
                    $scope.uploadStatus = 'success';
                    $scope.transitionTo('gpg-key.info', {gpgKeyId: response.id});
                    Notification.setSuccessMessage(translate('GPG key %s has been created.').replace('%s', response.name));
                } else {
                    Notification.setErrorMessage(translate("An error occurred while creating the GPG key: ") + response.displayMessage);
                    $scope.uploadStatus = 'error';
                }

                $scope.progress.uploading = false;
            }
        };
    }]
);
