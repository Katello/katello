/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionEnvironmentController
 *
 * @requires $scope
 * @requires ContentHostBulkAction
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 *
 * @description
 *   A controller for providing bulk action functionality for setting content view and environment
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionEnvironmentController',
    ['$scope', 'ContentHostBulkAction', 'Organization', 'CurrentOrganization', 'ContentView',
    function ($scope, ContentHostBulkAction, Organization, CurrentOrganization, ContentView) {

        function actionParams() {
            var params = $scope.nutupane.getAllSelectedResults();
            params['organization_id'] = CurrentOrganization;
            params['environment_id'] = $scope.selected.environment.id;
            params['content_view_id'] = $scope.selected.contentView.id;
            return params;
        }

        $scope.setState(false, [], []);
        $scope.selected = {
            environment: undefined,
            contentView: undefined
        };

        $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

        $scope.disableAssignButton = function (confirm) {
            return confirm || $scope.table.numSelected === 0 || $scope.state.working ||
                angular.isUndefined($scope.selected.environment) || angular.isUndefined($scope.selected.contentView);
        };

        $scope.$watch('selected.environment', function (environment) {
            if (environment) {
                $scope.fetchViews();
            }
        });

        $scope.fetchViews = function () {
            $scope.fetchingContentViews = true;

            ContentView.queryUnpaged({ 'environment_id': $scope.selected.environment.id }, function (response) {
                $scope.contentViews = response.results;
                $scope.fetchingContentViews = false;
            });
        };

        $scope.performAction = function () {
            $scope.setState(true, [], []);

            ContentHostBulkAction.environmentContentView(actionParams(), function (response) {
                $scope.setState(false, response.displayMessages.success, response.displayMessages.error);
            }, function (data) {
                $scope.setState(false, [], data.errors);
            });
        };
    }]
);
