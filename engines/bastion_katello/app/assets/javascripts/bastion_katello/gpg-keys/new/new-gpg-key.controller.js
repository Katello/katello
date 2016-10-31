/**
 * @ngdoc object
 * @name  Bastion.gpg-keys.controller:NewGPGKeyController
 *
 * @requires $scope
 * @requires $state
 * @requires translate
 * @requires GPGKey
 * @requires CurrentOrganization
 * @requires GlobalNotification
 *
 * @description
 *   Controls the creation of an empty GPGKey object for use by sub-controllers.
 */
angular.module('Bastion.gpg-keys').controller('NewGPGKeyController',
    ['$scope', '$state', 'translate', 'GPGKey', 'CurrentOrganization', 'GlobalNotification',
    function ($scope, $state, translate, GPGKey, CurrentOrganization, GlobalNotification) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

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
                    GlobalNotification.setSuccessMessage(translate('GPG key %s has been created.').replace('%s', response.name));
                } else {
                    $scope.errorMessages = [translate("An error occurred while creating the GPG key: ") + response.displayMessage];
                    $scope.uploadStatus = 'error';
                }

                $scope.progress.uploading = false;
            }
        };
    }]
);
