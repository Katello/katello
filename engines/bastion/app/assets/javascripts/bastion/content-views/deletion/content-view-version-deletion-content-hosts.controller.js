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
    ['$scope', '$location', 'Organization', 'CurrentOrganization', 'Nutupane', 'ContentHost',
    function ($scope, $location, Organization, CurrentOrganization, Nutupane, ContentHost) {

        var params, nutupane;

        $scope.validateEnvironmentSelection();
        params = {
            'organization_id':  CurrentOrganization,
            'content_view_id':  $scope.contentView.id,
            'sort_by':          'name',
            'sort_order':       'ASC'
        };
        nutupane = new Nutupane(ContentHost, params);

        nutupane.searchTransform = function (term) {
            var addition = "(environment_id:(" + $scope.selectedEnvironmentIds().join(" OR ") + "))";
            if (term === "" || term === undefined) {
                return addition;
            } else {
                return term +  " AND " + addition;
            }
        };
        $scope.detailsTable = nutupane.table;
        $scope.detailsTable.closeItem = function () {};

        $scope.environments = Organization.registerableEnvironments({organizationId: CurrentOrganization});
        $scope.initEnvironmentWatch($scope);

        $scope.selectedEnvironment = $scope.deleteOptions.contentHosts.environment;
        if ($scope.deleteOptions.contentHosts.contentView) {
            $scope.selectedContentViewId =  $scope.deleteOptions.contentHosts.contentView.id;
        }

        $scope.processSelection = function () {
            $scope.deleteOptions.contentHosts.environment = $scope.selectedEnvironment;
            $scope.deleteOptions.contentHosts.contentView = _.findWhere($scope.contentViewsForEnvironment,
                {id: $scope.selectedContentViewId});
            $scope.selectedEnvironment = undefined;
            $scope.selectedContentViewId = undefined;
            $scope.transitionToNext();
        };

        $scope.contentHostsLink = function () {
            var search = $scope.searchString($scope.contentView, $scope.deleteOptions.environments);
            return $scope.$state.href('content-hosts.index').url + '?search=' + search;
        };

        $scope.toggleHosts = function () {
            $scope.showHosts = !$scope.showHosts;
        };
    }]
);
