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
 * @name  Bastion.content-hosts.controller:ContentHostAddHostCollectionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires ContentHost
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for adding host collections to a content host.
 */
angular.module('Bastion.content-hosts').controller('ContentHostAddHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'ContentHost', 'Nutupane',
    function ($scope, $q, $location, translate, ContentHost, Nutupane) {
        var hostCollectionsPane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'search':      $location.search().search || "",
            'order':       'name ASC',
            'paged':       true,
            'id':            $scope.$stateParams.contentHostId
        };

        hostCollectionsPane = new Nutupane(ContentHost, params, 'availableHostCollections');
        $scope.hostCollectionsTable = hostCollectionsPane.table;

        $scope.addHostCollections = function (contentHost) {
            var deferred = $q.defer(),
                success,
                error,
                hostCollections,
                hostCollectionsToAdd;

            success = function (data) {
                $scope.successMessages = [translate('Added %x host collections to content host "%y".')
                    .replace('%x', $scope.hostCollectionsTable.numSelected).replace('%y', $scope.contentHost.name)];
                $scope.hostCollectionsTable.working = false;
                $scope.hostCollectionsTable.selectAll(false);
                hostCollectionsPane.refresh();
                $scope.contentHost.$get();
                deferred.resolve(data);
            };

            error = function (error) {
                deferred.reject(error.data.errors);
                $scope.errorMessages = error.data.errors['base'];
                $scope.hostCollectionsTable.working = false;
            };

            $scope.hostCollectionsTable.working = true;

            hostCollections = _.pluck($scope.contentHost.hostCollections, 'id');
            hostCollectionsToAdd = _.pluck($scope.hostCollectionsTable.getSelected(), 'id');
            contentHost["host_collection_ids"] = _.union(hostCollections, hostCollectionsToAdd);

            contentHost.$update({id: $scope.contentHost.uuid}, success, error);
            return deferred.promise;
        };
    }]
);
