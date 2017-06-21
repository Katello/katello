/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires $window
 * @requires $uibModal
 * @requires translate
 * @requires Nutupane
 * @requires Host
 * @requires HostBulkAction
 * @requires GlobalNotification
 * @requires CurrentOrganization
 * @requires ContentHostsHelper
 *
 * @description
 *   Provides the functionality specific to Content Hosts for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsController',
    ['$scope', '$q', '$state', '$location', '$window', '$uibModal', 'translate', 'Nutupane', 'Host', 'HostBulkAction', 'GlobalNotification', 'CurrentOrganization', 'ContentHostsHelper', 'ContentHostsModalHelper',
    function ($scope, $q, $state, $location, $window, $uibModal, translate, Nutupane, Host, HostBulkAction, GlobalNotification, CurrentOrganization, ContentHostsHelper, ContentHostsModalHelper) {
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
        $scope.controllerName = 'hosts';
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;
        $scope.nutupane = nutupane;

        // @TODO begin hack necessary because of foreman API bug http://projects.theforeman.org/issues/13877
        $scope.table.sortBy = function (column) {
            var sort = $scope.table.resource.sort,
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
            $scope.table.rows = [];
            $scope.nutupane.query();
        };
        // @TODO end hack

        nutupane.enableSelectAllResults();

        if ($location.search()['select_all']) {
            nutupane.table.initialSelectAll = true;
        }

        $scope.table.getHostStatusIcon = ContentHostsHelper.getHostStatusIcon;

        $scope.table = $scope.table;

        $scope.reloadSearch = function (search) {
            $scope.table.search(search);
            $state.go('content-hosts');
        };

        $scope.performDestroyHosts = function () {
            var destroyParams, success, error, deferred = $q.defer();

            destroyParams = $scope.nutupane.getAllSelectedResults();
            destroyParams['organization_id'] = CurrentOrganization;

            success = function (data) {
                deferred.resolve(data);
                $window.location = "/foreman_tasks/tasks/" + data.id;
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                angular.forEach(response.data.errors, function (responseError) {
                    GlobalNotification.setErrorMessage(responseError);
                });
            };

            HostBulkAction.destroyHosts(destroyParams, success, error);
            return deferred.promise;
        };
        $scope.getHostIds = function() {
            return $scope.nutupane.getAllSelectedResults('id');
        };

        ContentHostsModalHelper.resolveFunc = $scope.getHostIds;

        $scope.openHostCollectionsModal = function() {
            nutupane.invalidate();
            ContentHostsModalHelper.openHostCollectionsModal();
        };

        $scope.openPackagesModal = function () {
            nutupane.invalidate();
            ContentHostsModalHelper.openPackagesModal();
        };

        $scope.openErrataModal = function () {
            nutupane.invalidate();
            ContentHostsModalHelper.openErrataModal();
        };

        $scope.openEnvironmentModal = function () {
            nutupane.invalidate();
            ContentHostsModalHelper.openEnvironmentModal();
        };

        $scope.openSubscriptionsModal = function () {
            nutupane.invalidate();
            ContentHostsModalHelper.openSubscriptionsModal();
        };
    }]
);
