/**
 * @ngdoc object
 * @name  Bastion.gpg-keys.controller:NewGPGKeyController
 *
 * @requires $scope
 * @requires translate
 * @requires GPGKey
 * @requires CurrentOrganization
 * @requires GlobalNotification
 *
 * @description
 *   Controls the creation of an empty GPGKey object for use by sub-controllers.
 */
angular.module('Bastion.gpg-keys').controller('NewGPGKeyController',
    ['$scope', 'translate', 'GPGKey', 'CurrentOrganization', 'GlobalNotification',
    function ($scope, translate, GPGKey, CurrentOrganization, GlobalNotification) {
        $scope.errorMessages = [];

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
                    GlobalNotification.setSuccessMessage(translate('GPG key %s has been created.').replace('%s', content.name));
                } else {
                    $scope.errorMessages = [translate("An error occurred while creating the GPG key: ") + content.displayMessage];
                    $scope.uploadStatus = 'error';
                }

                $scope.progress.uploading = false;
            }
        };

    }]
);
