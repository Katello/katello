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
 * @name  Bastion.host-collections.controller:HostCollectionFormController
 *
 * @requires $scope
 * @requires $q
 * @requires HostCollection
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to HostCollections for creating a new host collection
 */
angular.module('Bastion.host-collections').controller('HostCollectionFormController',
    ['$scope', '$q', 'HostCollection', 'CurrentOrganization',
    function ($scope, $q, HostCollection, CurrentOrganization) {

        $scope.hostCollection = $scope.hostCollection || new HostCollection();

        $scope.save = function (hostCollection) {
            hostCollection['organization_id'] = CurrentOrganization;
            hostCollection.$save(success, error);
        };

        $scope.unlimited = true;
        $scope.hostCollection['max_content_hosts'] = -1;

        $scope.isUnlimited = function (hostCollection) {
            return hostCollection['max_content_hosts'] === -1;
        };

        $scope.inputChanged = function (hostCollection) {
            if ($scope.isUnlimited(hostCollection)) {
                $scope.unlimited = true;
            }
        };

        $scope.unlimitedChanged = function (hostCollection) {
            if ($scope.isUnlimited(hostCollection)) {
                $scope.unlimited = false;
                hostCollection['max_content_hosts'] = 1;
            }
            else {
                $scope.unlimited = true;
                hostCollection['max_content_hosts'] = -1;
            }
        };

        function success(response) {
            $scope.table.addRow(response);
            $scope.transitionTo('host-collections.details.info', {hostCollectionId: $scope.hostCollection.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.hostCollectionForm[field].$setValidity('', false);
                $scope.hostCollectionForm[field].$error.messages = errors;
            });
        }

    }]
);
