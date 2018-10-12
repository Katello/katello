/**
 * @ngdoc object
 * @name  Bastion.content-credentials.controller:NewContentCredentialController
 *
 * @requires $scope
 * @requires $state
 * @requires translate
 * @requires ContentCredential
 * @requires CurrentOrganization
 * @requires Notification
 *
 * @description
 *   Controls the creation of an empty ContentCredential object for use by sub-controllers.
 */
angular.module('Bastion.content-credentials').controller('NewContentCredentialController',
    ['$scope', '$state', 'translate', 'ContentCredential', 'CurrentOrganization', 'Notification',
    function ($scope, $state, translate, ContentCredential, CurrentOrganization, Notification) {
        $scope.panel = {loading: false};
        $scope.contentCredential = new ContentCredential();
        $scope.CurrentOrganization = CurrentOrganization;
        $scope.progress = {uploading: false};
        $scope.uploadURL = 'katello/api/v2/content_credentials?organization_id=' + CurrentOrganization;

        $scope.uploadContent = function (response) {
            if (response) {
                if (angular.isUndefined(response.errors)) {
                    $scope.uploadStatus = 'success';
                    $scope.transitionTo('content-credential.info', {contentCredentialId: response.id});
                    Notification.setSuccessMessage(translate('Content Credential %s has been created.').replace('%s', response.name));
                } else {
                    Notification.setErrorMessage(translate("An error occurred while creating the Content Credential: ") + response.displayMessage);
                    $scope.uploadStatus = 'error';
                }

                $scope.progress.uploading = false;
            }
        };
    }]
);
