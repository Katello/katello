/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc directive
 * @name Bastion.widgets.directive:orgSwitcher
 *
 * @requires $window
 * @requires $document
 * @requires Routes
 * @requires CurrentUser
 * @requires User
 * @requires CurrentOrganization
 * @requires Organization
 *
 * @description
 *  Used to provide an organization switcher for the logged in user.
 *
 * @example
 *  <span class="spinner"></span>
 *  <ul org-switcher></ul>
 */
angular.module('Bastion.widgets').directive('orgSwitcher',
    ['$window', '$document', 'Routes', 'CurrentUser', 'User', 'CurrentOrganization', 'Organization',
    function ($window, $document, Routes, CurrentUser, User, CurrentOrganization, Organization) {

    return {
        restrict: 'A',
        scope: true,
        templateUrl: 'widgets/views/org-switcher.html',

        controller: ['$scope', function ($scope) {
            $scope.visible = false;
            $scope.working = false;

            if (CurrentOrganization) {
                $scope.currentOrganization = Organization.get({'id': CurrentOrganization});
            }

            $scope.toggleVisibility = function () {
                $scope.visible = !$scope.visible;
            };

            $scope.refresh = function () {
                $scope.working = true;
                $scope.user = User.get({'id': CurrentUser}, function (user) {
                    $scope.working = false;
                    $scope.favoriteOrg = user.preferences.user['default_org'] || null;
                });
            };

            $scope.selectOrg = function (organization) {
                $scope.visible = false;

                User.selectOrg(organization.id, function () {
                    $window.location = Routes.dashboardIndexPath();
                });
            };

            $scope.setDefaultOrg = function (event, organization) {
                var organizationId = organization.id;
                if (organization.id === $scope.favoriteOrg) {
                    organizationId = null;
                }

                User.setDefaultOrg($scope.user.id, organizationId, function () {
                    $scope.favoriteOrg = organizationId;
                });
            };

            $scope.$watch('visible', function (newValue, oldValue) {
                if (newValue && (newValue !== oldValue)) {
                    $scope.refresh();
                }
            });

            // Hide the org switcher menu if the user clicks outside of it
            var orgSwitcherMenu = angular.element('#organizationSwitcher');
            $document.bind('click', function (event) {
                var target = angular.element(event.target);
                if (!orgSwitcherMenu.find(target).length) {
                    $scope.visible = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                }
            });
        }]
    };
}]);
