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
 * @name  Bastion.content-hosts.controller:ContentHostRegisterController
 *
 * @requires $scope
 * @requires $location
 * @requires Capsule
 * @requires Organization
 * @requires CurrentOrganization
 * @requires BastionConfig
 *
 * @description
 *     Provides values to populate the code commands for registering a content host.
 */
angular.module('Bastion.content-hosts').controller('ContentHostRegisterController',
    ['$scope', '$location', 'Capsule', 'Organization', 'CurrentOrganization', 'BastionConfig',
    function ($scope, $location, Capsule, Organization, CurrentOrganization, BastionConfig) {

        $scope.organization = Organization.get({id: CurrentOrganization});
        $scope.consumerCertRPM = BastionConfig.consumerCertRPM;
        $scope.katelloHostname = $location.host();
        $scope.noCapsulesFound = true;

        $scope.capsules = Capsule.queryUnpaged(function (data) {
            var defaultCapsule = _.filter(data.results, function (result) {
                var featureNames = _.pluck(result.features, 'name');
                return _.contains(featureNames, 'Pulp');
            });

            $scope.noCapsulesFound = _.isEmpty(data.results);
            $scope.selectedCapsule = _.isEmpty(defaultCapsule) ? data.results[0] : defaultCapsule[0];
        });


        $scope.hostname = function (url) {
            if (url) {
                url = url.split('://')[1].split(':')[0];
            }

            return url;
        };

    }]
);
