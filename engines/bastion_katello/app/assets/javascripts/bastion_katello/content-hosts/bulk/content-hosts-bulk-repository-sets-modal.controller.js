/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkRepositorySetsModalController
 *
 * @requires $scope
 * @requires $location
 * @requires $uibModalInstance
 * @requires translate
 * @requires Nutupane
 * @requires HostBulkAction
 * @requires RepositorySet
 * @requires CurrentOrganization
 * @requires Notification
 * @requires hostIds
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkRepositorySetsModalController',
    ['$scope', '$location', '$uibModalInstance', 'translate', 'Nutupane', 'HostBulkAction', 'RepositorySet', 'CurrentOrganization', 'Notification', 'hostIds',
    function ($scope, $location, $uibModalInstance, translate, Nutupane, HostBulkAction, RepositorySet, CurrentOrganization, Notification, hostIds) {
        var nutupane, nutupaneParams;

        $scope.repositorySets = {
            action: null
        };

        nutupaneParams = {
            'organization_id': CurrentOrganization,
            'offset': 0,
            'paged': true,
            'enabled': true,
            'with_custom': true
        };

        nutupane = new Nutupane(RepositorySet, nutupaneParams,
          'queryPaged', {disableAutoLoad: true});
        $scope.controllerName = 'katello_repository_sets';
        nutupane.masterOnly = true;
        nutupane.setSearchKey('repoSetsSearch');
        nutupane.load();

        $scope.table = nutupane.table;

        $scope.confirmRepositorySetAction = function (action) {
            $scope.repositorySets.confirm = true;
            $scope.repositorySets.action = action;
        };

        $scope.performRepositorySetAction = function () {
            var params, action, success, error, contentOverrides;

            action = $scope.repositorySets.action;
            params = hostIds;
            params['organization_id'] = CurrentOrganization;
            contentOverrides = [];
            angular.forEach(nutupane.getAllSelectedResults('id').included.resources, function (repositorySet) {
                var value, remove;

                if (action === 'enable') {
                    value = true;
                    remove = false;
                } else if (action === 'disable') {
                    value = false;
                    remove = false;
                } else if (action === 'reset') {
                    value = true;
                    remove = true;
                }
                contentOverrides.push({
                    'content_label': repositorySet.label,
                    name: 'enabled',
                    value: value,
                    remove: remove
                });
            });
            params['content_overrides'] = contentOverrides;

            $scope.repositorySets.action = null;

            success = function (response) {
                nutupane.invalidate();
                $scope.ok();
                $scope.transitionTo('content-hosts.bulk-task', {taskId: response.id});
            };

            error = function (response) {
                angular.forEach(response.data.errors, function (responseError) {
                    Notification.setErrorMessage(responseError);
                });
                $scope.editMode = true;
            };

            HostBulkAction.updateRepositorySets(params, success, error);
        };

        $scope.ok = function () {
            $uibModalInstance.close();
        };

        $scope.cancel = function () {
            $uibModalInstance.dismiss('cancel');
        };

        $scope.repositorySetsAction = function (action) {
            $scope.repositorySets.action = action;
            $scope.repositorySets.working = true;
        };
    }]
);
