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
 * @name  Bastion.systems.controller:ActivationKeyHostCollectionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires ActivationKey
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the list host collections details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'ActivationKey', 'Nutupane',
    function ($scope, $q, $location, translate, ActivationKey, Nutupane) {
        var hostCollectionsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'id':          $scope.$stateParams.activationKeyId,
            'search':      $location.search().search || "",
            'order':       'name ASC',
            'paged':       true
        };

        hostCollectionsPane = new Nutupane(ActivationKey, params, 'hostCollections');
        $scope.hostCollectionsTable = hostCollectionsPane.table;

        $scope.removeHostCollections = function () {
            var data,
                success,
                error,
                deferred = $q.defer(),
                hostCollectionsToRemove = _.pluck($scope.hostCollectionsTable.getSelected(), 'id');

            data = {
                "activation_key": {
                    "host_collection_ids": hostCollectionsToRemove
                }
            };

            success = function (data) {
                $scope.successMessages = [translate('Removed %x host collections from activation key "%y".')
                    .replace('%x', $scope.hostCollectionsTable.numSelected)
                    .replace('%y', $scope.activationKey.name)];
                $scope.hostCollectionsTable.working = false;
                $scope.hostCollectionsTable.selectAll(false);
                hostCollectionsPane.refresh();
                $scope.activationKey.$get();
                deferred.resolve(data);
            };

            error = function (error) {
                deferred.reject(error.data.errors);
                $scope.errorMessages = error.data.errors;
                $scope.hostCollectionsTable.working = false;
            };

            $scope.hostCollectionsTable.working = true;
            ActivationKey.removeHostCollections({id: $scope.activationKey.id}, data, success, error);
            return deferred.promise;
        };
    }]
);
