/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkHostCollectionsModalController
 *
 * @requires $scope
 * @requires $location
 * @requires $uibModalInstance
 * @requires translate
 * @requires Nutupane
 * @requires HostBulkAction
 * @requires HostCollection
 * @requires CurrentOrganization
 * @requires Notification
 * @requires hostIds
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkHostCollectionsModalController',
    ['$scope', '$location', '$uibModalInstance', 'translate', 'Nutupane', 'HostBulkAction', 'HostCollection', 'CurrentOrganization', 'Notification', 'hostIds',
    function ($scope, $location, $uibModalInstance, translate, Nutupane, HostBulkAction, HostCollection, CurrentOrganization, Notification, hostIds) {
        var nutupane, nutupaneParams;

        $scope.hostCollections = {
            action: null
        };

        nutupaneParams = {
            'organization_id': CurrentOrganization,
            'offset': 0,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        nutupane = new Nutupane(HostCollection, nutupaneParams, 'queryPaged');
        $scope.controllerName = 'katello_host_collections';
        nutupane.masterOnly = true;

        $scope.table = nutupane.table;
        $scope.confirmHostCollectionAction = function (action) {
            $scope.hostCollections.confirm = true;
            $scope.hostCollections.action = action;
        };

        $scope.performHostCollectionAction = function () {
            var params, action, success, error;

            action = $scope.hostCollections.action;
            params = hostIds;
            params['organization_id'] = CurrentOrganization;
            params['host_collection_ids'] = nutupane.getAllSelectedResults('id').included.ids;

            $scope.hostCollections.action = null;

            success = function (data) {
                angular.forEach(data.displayMessages, function (message) {
                    Notification.setSuccessMessage(message);
                });
                nutupane.invalidate();
            };

            error = function (response) {
                angular.forEach(response.data.errors, function (responseError) {
                    Notification.setErrorMessage(responseError);
                });
                $scope.editMode = true;
            };

            if (action === 'add') {
                HostBulkAction.addHostCollections(params, success, error);
            } else if (action === 'remove') {
                HostBulkAction.removeHostCollections(params, success, error);
            }
        };

        $scope.ok = function () {
            $uibModalInstance.close();
        };

        $scope.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };
    }]
);
