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
 * @name  Bastion.systems.controller:ActivationKeyAddHostCollectionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires ActivationKey
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for adding host collections to an activation key.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyAddHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'ActivationKey', 'Nutupane',
    function ($scope, $q, $location, translate, ActivationKey, Nutupane) {
        var hostCollectionsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true,
            'id':          $scope.$stateParams.activationKeyId
        };

        hostCollectionsPane = new Nutupane(ActivationKey, params, 'availableHostCollections');
        $scope.hostCollectionsTable = hostCollectionsPane.table;

        $scope.addHostCollections = function () {
            var data,
                success,
                error,
                deferred = $q.defer(),
                hostCollectionsToAdd = _.pluck($scope.hostCollectionsTable.getSelected(), 'id');

            data = {
                "activation_key": {
                    "host_collection_ids": hostCollectionsToAdd
                }
            };

            success = function (data) {
                $scope.successMessages = [translate('Added %x host collections to activation key "%y".')
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
                $scope.errorMessages = error.data.errors['base'];
                $scope.hostCollectionsTable.working = false;
            };

            $scope.hostCollectionsTable.working = true;
            ActivationKey.addHostCollections({id: $scope.activationKey.id}, data, success, error);
            return deferred.promise;
        };
    }]
);
