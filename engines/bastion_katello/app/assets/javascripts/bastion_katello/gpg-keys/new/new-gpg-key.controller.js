/**
 * @ngdoc object
 * @name  Bastion.gpg-keys.controller:NewGPGKeyController
 *
 * @requires $scope
 * @requires GPGKey
 * @requires CurrentOrganization
 *
 * @description
 *   Controls the creation of an empty GPGKey object for use by sub-controllers.
 */
angular.module('Bastion.gpg-keys').controller('NewGPGKeyController',
    ['$scope', 'GPGKey', 'CurrentOrganization', 'GlobalNotification',
    function ($scope, GPGKey, CurrentOrganization, GlobalNotification) {

        $scope.panel = {loading: false};
        $scope.gpgKey = new GPGKey();
        $scope.CurrentOrganization = CurrentOrganization;
        $scope.progress = {uploading: false};
        $scope.contentFormType = 'paste';
        $scope.uploadURL = '/katello/api/v2/gpg_keys?organization_id=' + CurrentOrganization;

        $scope.uploadContent = function (content) {
            if (content) {
                if (angular.isUndefined(content.errors)) {
                    $scope.table.addRow(content);
                    $scope.uploadStatus = 'success';
                    $scope.transitionTo('gpgKeys.index');
                } else {
                    GlobalNotification.setErrorMessage("An error occurred while creating the GPG key: " + content.displayMessage);
                    $scope.uploadStatus = 'error';
                }

                $scope.progress.uploading = false;
            }
        };

    }]
);
