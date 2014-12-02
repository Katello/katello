/**
 Copyright 2014 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

(function () {

    /**
     * @ngdoc object
     * @name Bastion.organizations.config
     *
     * @requires $stateProvider
     *
     * @description
     *   State routes defined for the organizations module.
     */
    function OrganizationRoutes($stateProvider) {
        $stateProvider.state('organizations', {
            abstract: true,
            template: '<div ui-view></div>'
        })
        .state('organizations.select', {
            url: '/select_organization?toState',
            permission: 'view_organizations',
            controller: 'OrganizationSelectorController',
            templateUrl: 'organizations/views/organization-selector.html'
        });
    }

    angular.module('Bastion.organizations').config(OrganizationRoutes);

    OrganizationRoutes.$inject = ['$stateProvider'];

})();
