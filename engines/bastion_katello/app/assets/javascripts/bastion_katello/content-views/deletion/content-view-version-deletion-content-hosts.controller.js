/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewVersionDeletionContentHosts
 *
 * @requires $scope
 * @requires $location
 * @requires Organization
 * @requires CurrentOrganization
 * @requires Nutupane
 * @requires ContentHost
 *
 * @description
 *   Provides functionality for picking which content view and environment to move Content Hosts to
 *   as part of content view version deletion.
 */
angular.module('Bastion.content-views').controller('ContentViewVersionDeletionContentHostsController',
    ['$scope', '$location', 'Organization', 'CurrentOrganization', 'Nutupane', 'Host',
    function ($scope, $location, Organization, CurrentOrganization, Nutupane, Host) {

        var params, nutupane;

        $scope.validateEnvironmentSelection();
        params = {
            'organization_id': CurrentOrganization,
            'content_view_id': $scope.contentView.id,
            'sort_by': 'name',
            'sort_order': 'ASC'
        };
        nutupane = new Nutupane(Host, params);
        $scope.controllerName = 'hosts';

        nutupane.searchTransform = function (term) {
            var addition,
                envIdClausses = [];

            angular.forEach($scope.selectedEnvironmentIds(), function(envId) {
                envIdClausses.push("lifecycle_environment_id = " + envId);
            });
            addition = '(' + envIdClausses.join(" OR ") + ')';
            addition = addition + " AND content_view_id = " + $scope.contentView.id;
            if (term === "" || angular.isUndefined(term)) {
                return addition;
            }

            return term + " AND " + addition;
        };
        $scope.table = nutupane.table;
        $scope.table.closeItem = function () {};

        $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});
        $scope.initEnvironmentWatch($scope);

        $scope.selectedEnvironment = $scope.deleteOptions.contentHosts.environment;
        if ($scope.deleteOptions.contentHosts.contentView) {
            $scope.selectedContentViewId = $scope.deleteOptions.contentHosts.contentView.id;
        }

        $scope.processSelection = function () {
            $scope.deleteOptions.contentHosts.environment = $scope.selectedEnvironment;
            $scope.deleteOptions.contentHosts.contentView = _.find($scope.contentViewsForEnvironment,
                {id: $scope.selectedContentViewId});
            $scope.selectedEnvironment = undefined;
            $scope.selectedContentViewId = undefined;
            $scope.transitionToNext();
        };

        $scope.contentHostsLink = function () {
            var search = $scope.searchString($scope.contentView, $scope.deleteOptions.environments);
            return $scope.$state.href('content-hosts') + '?search=' + search;
        };

        $scope.toggleHosts = function () {
            $scope.showHosts = !$scope.showHosts;
        };
    }]
);
