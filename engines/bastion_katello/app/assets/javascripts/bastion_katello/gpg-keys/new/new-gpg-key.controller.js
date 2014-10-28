/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

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
    ['$scope', 'GPGKey', 'CurrentOrganization',
    function ($scope, GPGKey, CurrentOrganization) {

        $scope.panel = {loading: false};
        $scope.gpgKey = new GPGKey();
        $scope.CurrentOrganization = CurrentOrganization;
        $scope.progress = {uploading: false};
        $scope.contentFormType = 'paste';
        $scope.uploadURL = '/katello/api/v2/gpg_keys?organization_id=' + CurrentOrganization;

        $scope.uploadContent = function (content) {
            if (content) {
                if (content.errors === undefined) {
                    $scope.table.addRow(content);
                    $scope.uploadStatus = 'success';
                    $scope.transitionTo('gpgKeys.index');
                } else {
                    $scope.errorMessages = [content.displayMessage];
                    $scope.uploadStatus = 'error';
                }

                $scope.progress.uploading = false;
            }
        };

    }]
);
