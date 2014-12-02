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
 * @name  Bastion.content-views.controller:ContentViewPromotionController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires ContentViewVersion
 * @requires Organization
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewPromotionController',
    ['$scope', '$q', 'translate', 'ContentViewVersion', 'Organization', 'CurrentOrganization',
    function ($scope, $q, translate, ContentViewVersion, Organization, CurrentOrganization) {

        $scope.promotion = {};
        $scope.working = false;

        $scope.version = ContentViewVersion.get({id: $scope.$stateParams.versionId});
        $scope.currentOrganization = CurrentOrganization;
        $scope.availableEnvironments = Organization.paths({id: CurrentOrganization, 'permission_type': 'promotable'});

        $q.all([$scope.availableEnvironments.$promise, $scope.version.$promise]).then(function (args) {
            var environments = args[0],
                version = args[1];

            angular.forEach(environments, function (path) {
                angular.forEach(path.environments, function (environment) {
                    environment.disabled = $scope.checkDisabled(environment, version.environments);
                });
            });

            $scope.working = true;
        });

        $scope.checkDisabled = function (env, environments) {
            var enabled = false,
                envIds = _.pluck(environments, 'id');

            if (!env.prior) {
                env.prior = {};
            }

            if (envIds.indexOf(env.id) !== -1) {
                //if version is already promoted to the environment
                enabled = false;
            } else if (env.library) {
                //allow library for all versions
                enabled = true;
            } else if (envIds.length !== 0 && envIds.indexOf(env.prior.id) !== -1) {
                //if environment is a successor an existing environment
                enabled = true;
            }

            return !enabled;
        };

        $scope.promote = function () {
            $scope.promoting = true;
            ContentViewVersion.promote({id: $scope.version.id, 'environment_id': $scope.selectedEnvironment.id},
                success, failure);
        };

        function success() {
            var message = translate('Successfully initiated promotion of %cv version %ver to %env.');
            message = message.replace('%cv', $scope.contentView.name).replace('%env', $scope.selectedEnvironment.name);
            message = message.replace('%ver', $scope.version.version);
            $scope.promoting = false;
            $scope.$parent.successMessages = [message];
            $scope.transitionTo('content-views.details.versions', {contentViewId: $scope.contentView.id});
        }

        function failure(response) {
            $scope.promoting = false;
            $scope.$parent.errorMessages = [response.data.displayMessage];
        }

    }]
);
