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
 * @ngdoc module
 * @name  Bastion.system-groups
 *
 * @description
 *   Module for system groups related functionality.
 */
angular.module('Bastion.system-groups', ['ngResource', 'Bastion.utils', 'ui.router']);

angular.module('Bastion.system-groups').config(['$stateProvider', function($stateProvider) {
    var templatePrefix = '../';

    $stateProvider.state('system-groups', {
        abstract: true,
        controller: 'SystemGroupsController',
        templateUrl: templatePrefix + 'system-groups/views/system-groups.html'
    })
    .state('system-groups.index', {
        url: '/system-groups',
        views: {
            'table': {
                templateUrl: templatePrefix + 'system-groups/views/system-groups-table-full.html'
            }
        }
    })
    .state('system-groups.new', {
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: templatePrefix + 'system-groups/views/system-groups-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NewSystemGroupController',
                templateUrl: templatePrefix + 'system-groups/new/views/system-group-new.html'
            }
        }
    })
    .state('system-groups.new.form', {
        url: '/system-groups/new',
        collapsed: true,
        controller: 'SystemGroupFormController',
        templateUrl: templatePrefix + 'system-groups/new/views/system-group-new-form.html'
    });

    $stateProvider.state("system-groups.details", {
        abstract: true,
        url: '/system-groups/:systemGroupId',
        collapsed: true,
        views: {
            'table': {
                templateUrl: templatePrefix + 'system-groups/views/system-groups-table-collapsed.html'
            },
            'action-panel': {
                controller: 'SystemGroupDetailsController',
                templateUrl: templatePrefix + 'system-groups/details/views/system-group-details.html'
            }
        }
    })
    .state('system-groups.details.info', {
        url: '/info',
        collapsed: true,
        controller: 'SystemGroupDetailsInfoController',
        templateUrl: templatePrefix + 'system-groups/details/views/system-group-info.html'
    })
    .state('system-groups.details.systems', {
        abstract: true,
        collapsed: true,
        templateUrl: templatePrefix + 'system-groups/details/views/system-group-systems.html'
    })
    .state('system-groups.details.systems.list', {
        url: '/systems',
        collapsed: true,
        controller: 'SystemGroupSystemsController',
        templateUrl: templatePrefix + 'system-groups/details/views/system-group-systems-list.html'
    })
    .state('system-groups.details.systems.add', {
        url: '/add-systems',
        collapsed: true,
        controller: 'SystemGroupAddSystemsController',
        templateUrl: templatePrefix + 'system-groups/details/views/system-group-add-systems.html'
    })
    .state('system-groups.details.actions', {
        url: '/actions',
        collapsed: true,
        templateUrl: templatePrefix + 'system-groups/details/views/system-group-actions.html'
    });



}]);
