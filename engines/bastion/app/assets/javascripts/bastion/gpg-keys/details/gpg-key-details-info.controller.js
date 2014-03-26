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
 * @name  Bastion.gpgKeys.controller:GPGKeyDetailsInfoController
 *
 * @requires $scope
 * @requires GPGKey
 * @requires translate
 *
 * @description
 *   Provides the functionality for the gpgKey details action pane.
 */
angular.module('Bastion.gpg-keys').controller('GPGKeyDetailsInfoController',
    ['$scope', 'GPGKey', 'translate', function ($scope, GPGKey, translate) {

        $scope.panel = $scope.panel || {loading: false};
        $scope.progress = {uploading: false};

        $scope.gpgKey = $scope.gpgKey || GPGKey.get({id: $scope.$stateParams.gpgKeyId}, function () {
            $scope.panel.loading = false;
        });

        $scope.gpgKey.$promise.then(function () {
            $scope.uploadURL = $scope.RootURL + '/api/v2/gpg_keys/' + $scope.gpgKey.id + '/content';
        });

        $scope.uploadContent = function (content) {
            if (content && (content !== "Please wait...")) {
                if (content.status === 'success') {
                    $scope.$parent.successMessages = [translate('GPG Key successfully uploaded')];
                    $scope.uploadStatus = 'success';
                    $scope.gpgKey.$get();
                } else {
                    $scope.$parent.errorMessages = [content.displayMessage];
                    $scope.uploadStatus = 'error';
                }

                $scope.progress.uploading = false;
            }
        };

    }]
);
