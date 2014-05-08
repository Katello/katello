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
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionHostCollectionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires ContentHostsBulkAction
 * @requires HostCollection
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionHostCollectionsController',
    ['$scope', '$q', '$location', 'translate', 'Nutupane', 'ContentHostBulkAction', 'HostCollection', 'CurrentOrganization',
    function ($scope, $q, $location, translate, Nutupane, ContentHostBulkAction, HostCollection, CurrentOrganization) {
        var hostCollectionNutupane, params;

        $scope.hostCollections = {
            action: null
        };
        $scope.setState(false, [], []);

        params = {
            'organization_id':  CurrentOrganization,
            'offset':           0,
            'sort_by':          'name',
            'sort_order':       'ASC',
            'paged':            true
        };

        hostCollectionNutupane = new Nutupane(HostCollection, params);

        $scope.setState(false, [], []);
        $scope.detailsTable = hostCollectionNutupane.table;
        $scope.detailsTable.closeItem = function () {};

        $scope.confirmHostCollectionAction = function (action) {
            $scope.hostCollections.confirm = true;
            $scope.hostCollections.action = action;
        };

        $scope.performHostCollectionAction = function () {
            var params, action, success, error, deferred = $q.defer();

            action = $scope.hostCollections.action;
            params = $scope.nutupane.getAllSelectedResults('id');
            params['organization_id'] = CurrentOrganization;
            params['host_collection_ids'] = hostCollectionNutupane.getAllSelectedResults('id').included.ids;

            $scope.hostCollections.action = null;
            $scope.setState(true, [], []);

            success = function (data) {
                deferred.resolve(data);
                $scope.setState(false, data["displayMessages"], []);
                hostCollectionNutupane.refresh();
            };

            error = function (error) {
                deferred.reject(error.data["errors"]);
                $scope.setState(false, [], [error.data.displayMessage]);
                $scope.editMode = true;
            };

            if (action === 'add') {
                ContentHostBulkAction.addHostCollections(params, success, error);
            } else if (action === 'remove') {
                ContentHostBulkAction.removeHostCollections(params, success, error);
            }

            return deferred.promise;
        };

    }]
);
