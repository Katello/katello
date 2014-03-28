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
 * @name  Bastion.content-views.controller:ContentViewVersionsController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentViewVersion
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewVersionsController',
    ['$scope', 'translate', function ($scope, translate) {

        $scope.table = {};

        $scope.reloadVersions();

        $scope.$on('$destroy', function () {
            _.each($scope.versions, function (version) {
                if (version.task) {
                    version.task.unregisterAll();
                }
            });
        });

        $scope.status = function (version) {
            var promoteCount = version['active_history'].length,
                publish = _.findWhere(version['active_history'], {publish: true});

            if (publish) {
                promoteCount = promoteCount - 1;
            }
            return statusMessage(publish, promoteCount);
        };

        $scope.hideProgress = function (version) {
            return version['active_history'].length === 0 || (version.task.state === 'stopped' &&
                version.task.progressbar.type === 'success');
        };

        function statusMessage(isPublishing, promoteCount) {
            var status = '';
            if (promoteCount > 1) {
                if (isPublishing) {
                    status = translate("Publishing and promoting to %count environments.").replace(
                        '%count', promoteCount);
                }
                else {
                    status = translate("Promoting to %count environments.").replace('%count', promoteCount);
                }
            } else if (promoteCount === 1 || isPublishing) {
                if (isPublishing) {
                    status = translate("Publishing and promoting to 1 environment.");
                }
                else {
                    status =  translate("Promoting to 1 environment.");
                }
            }
            return status;
        }
    }]
);
