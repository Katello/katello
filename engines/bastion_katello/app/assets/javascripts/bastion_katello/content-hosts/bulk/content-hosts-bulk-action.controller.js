/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires HostBulkAction
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionController',
    ['$scope', '$q', '$window', '$location', 'translate', 'HostBulkAction', 'CurrentOrganization',
    function ($scope, $q, $window, $location, translate, HostBulkAction, CurrentOrganization) {
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.showConfirm = false;

        $scope.unregisterContentHosts = {
            confirm: false,
            workingMode: false
        };

        $scope.state = {
            successMessages: [],
            errorMessages: [],
            working: false
        };

        $scope.setState = function (working, success, error) {
            $scope.state.working = working;
            $scope.state.successMessages = success;
            $scope.state.errorMessages = error;
        };

        $scope.showConfirmDialog = function () {
            $scope.showConfirm = true;
        };

        $scope.hideConfirmDialog = function () {
            $scope.showConfirm = false;
        };

        $scope.actionParams = {
            ids: []
        };

        $scope.showNoSelectionWarning = function () {
            return $scope.nutupane.table.numSelected === 0 && !$scope.isState('content-hosts.bulk-actions.task-details');
        };

        $scope.performDestroyHosts = function () {
            var params, success, error, deferred = $q.defer();

            $scope.unregisterContentHosts.confirm = false;
            $scope.state.working = true;

            params = $scope.nutupane.getAllSelectedResults();
            params['organization_id'] = CurrentOrganization;

            success = function (data) {
                deferred.resolve(data);
                $scope.setState(false, [], []);
                $window.location = "/foreman_tasks/tasks/" + data.id;
            };

            error = function (response) {
                deferred.reject(response.data.errors);
                $scope.setState(false, [], response.data.errors);
            };

            HostBulkAction.destroyHosts(params, success, error);

            return deferred.promise;
        };

    }]
);
