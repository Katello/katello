/**
* Copyright 2015 Red Hat, Inc.
*
* This software is licensed to you under the GNU General Public
* License as published by the Free Software Foundation; either version
* 2 of the License (GPLv2) or (at your option) any later version.
* There is NO WARRANTY for this software, express or implied,
* including the implied warranties of MERCHANTABILITY,
* NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
* have received a copy of GPLv2 along with this software; if not, see
* http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
**/


(function () {
    'use strict';

    /**
    * @ngdoc controller
    * @name Bastion.organizations.controller:OrganizationSelectorController
    *
    * @description
    *     Selecting an organization
    */
    function OrganizationSelectorController($scope, Organization, CurrentOrganization, $window) {
        var transitionState;

        $scope.selectedOrganization = {};

        Organization.queryUnpaged(function (response) {
            $scope.organizations = response.results;
        });

        $scope.selectOrganization = function (organization) {
            var label = organization.id + '-' + organization.name.replace("'", '').replace(".", '');

            Organization.select({label: label}).$promise.catch(function () {
                $window.location.href = transitionState;
            });
        };

        $scope.$on('$stateChangeSuccess', function (event, toState, toParams) {
            transitionState = toParams.toState;

            if (CurrentOrganization) {
                $window.location.href = transitionState;
            }
        });
    }

    angular
        .module('Bastion.organizations')
        .controller('OrganizationSelectorController', OrganizationSelectorController);

    OrganizationSelectorController.$inject = ['$scope', 'Organization', 'CurrentOrganization', '$window'];
})();
