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
 * @name Katello.directive:orgSwitcher
 *
 * @requires $http
 * @requires Routes
 *
 * @description
 *  Used to provide an organization switcher for the logged in user.  Currently simply stuffs
 *  _allowed_orgs.html.haml into the #allowed-orgs ul element.
 *
 *  TODO: angularize this directive.
 *
 * @example
 *  <span class="spinner"></span>
 *  <ul org-switcher></ul>
 */
angular.module('Katello.widgets').directive('orgSwitcher', ['$http', 'Routes', function($http, Routes) {
    return {
        restrict: 'A',
        transclude: true,

        controller: ['$scope', '$element', function($scope, $element) {
            var $spinner = $element.parent().find('.spinner');

            $scope.orgSwitcher = {
                visible: false
            };

            $scope.orgSwitcher.toggleVisibility = function() {
                $scope.orgSwitcher.visible = !$scope.orgSwitcher.visible;
            };

            $spinner.fadeIn();
            $scope.orgSwitcher.refresh = function() {
                $http.get(Routes.allowedOrgsUserSessionPath()).then(function(response) {
                    $spinner.fadeOut();
                    $element.html(response.data);
                });
            };

            $scope.$watch('orgSwitcher.visible', function(newValue, oldValue) {
                if (newValue && (newValue !== oldValue)) {
                    // Refresh the list of organizations
                    $scope.orgSwitcher.refresh();
                }
            });

        }]
    };
}]);
