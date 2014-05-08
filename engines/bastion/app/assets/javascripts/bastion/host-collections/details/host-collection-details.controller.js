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
 * @name  Bastion.host-collections.controller:HostCollectionDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires HostCollection
 *
 * @description
 *   Provides the functionality for the host collection details action pane.
 */
angular.module('Bastion.host-collections').controller('HostCollectionDetailsController',
    ['$scope', '$state', '$q', 'translate', 'HostCollection',
    function ($scope, $state, $q, translate, HostCollection) {
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.copyErrorMessages = [];

        if ($scope.hostCollection) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.hostCollection = HostCollection.get({id: $scope.$stateParams.hostCollectionId}, function (hostCollection) {
            $scope.$broadcast('hostCollection.loaded', hostCollection);
            $scope.panel.loading = false;
        });

        $scope.save = function (hostCollection) {
            var deferred = $q.defer();

            hostCollection.$update(function (response) {
                deferred.resolve(response);
                $scope.successMessages.push(translate('Host Collection updated'));
                $scope.table.replaceRow(response);
            }, function (response) {
                deferred.reject(response);
                $scope.errorMessages.push(translate("An error occurred saving the Host Collection: ") + response.data.displayMessage);
            });
            return deferred.promise;
        };

        $scope.copy = function (newName) {
            HostCollection.copy({id: $scope.hostCollection.id, 'host_collection': {name: newName}}, function (response) {
                $scope.showCopy = false;
                $scope.table.addRow(response);
                $scope.transitionTo('host-collections.details.info', {hostCollectionId: response['id']});
            }, function (response) {
                $scope.copyErrorMessages.push(response.data.displayMessage);
            });
        };

        $scope.removeHostCollection = function (hostCollection) {
            var id = hostCollection.id;

            hostCollection.$delete(function () {
                $scope.removeRow(id);
                $scope.transitionTo('host-collections.index');
                $scope.successMessages.push(translate('Host Collection removed.'));
            }, function (response) {
                $scope.errorMessages.push(translate("An error occurred removing the Host Collection: ") + response.data.displayMessage);
            });
        };

    }]
);
