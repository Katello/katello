/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires ContentHost
 * @requires CurrentOrganization
 * @requires ContentHostsHelper
 *
 * @description
 *   Provides the functionality specific to Content Hosts for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsController',
    ['$scope', '$state', '$location', 'translate', 'Nutupane', 'Host', 'CurrentOrganization', 'ContentHostsHelper',
    function ($scope, $state, $location, translate, Nutupane, Host, CurrentOrganization, ContentHostsHelper) {
        var nutupane, params;

        $scope.successMessages = [];
        $scope.errorMessages = [];

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC'
        };

        nutupane = new Nutupane(Host, params);
        $scope.contentHostTable = nutupane.table;
        $scope.removeRow = nutupane.removeRow;
        $scope.nutupane = nutupane;
        $scope.controllerName = 'katello_systems';

        // @TODO begin hack necessary because of foreman API bug http://projects.theforeman.org/issues/13877
        $scope.contentHostTable.sortBy = function (column) {
            var sort = $scope.contentHostTable.resource.sort,
                sortOrder;
            if (!column) {
                return;
            }

            params.sort = column.id;
            if (column.id === sort.by) {
                sortOrder = (sort.order === 'ASC') ? 'DESC' : 'ASC';
            } else {
                sortOrder = 'ASC';
            }

            params.order = [column.id, sortOrder].join(' ');

            column.sortOrder = sortOrder;
            column.active = true;
            $scope.contentHostTable.rows = [];
            $scope.nutupane.query();
        };
        // @TODO end hack

        nutupane.enableSelectAllResults();

        if ($location.search()['select_all']) {
            nutupane.table.initialSelectAll = true;
        }

        $scope.contentHostTable.getSubscriptionStatusColor = ContentHostsHelper.getSubscriptionStatusColor;
        $scope.contentHostTable.getGlobalStatusColor = ContentHostsHelper.getGlobalStatusColor;

        $scope.contentHostTable.closeItem = function () {
            $scope.transitionTo('content-hosts.index');
        };

        $scope.table = $scope.contentHostTable;

        $scope.unregisterContentHost = function (contentHost) {
            contentHost.$remove(function () {
                $scope.removeRow(contentHost.id);
                $scope.successMessages.push(translate('Content Host %s has been deleted.').replace('%s', contentHost.name));
                $scope.transitionTo('content-hosts.index');
            });
        };

        $scope.reloadSearch = function (search) {
            $scope.table.search(search);
            $state.go('content-hosts.index');
        };
    }]
);
