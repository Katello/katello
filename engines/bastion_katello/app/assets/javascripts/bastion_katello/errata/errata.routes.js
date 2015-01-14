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

/**
 * @ngdoc object
 * @name Bastion.errata.config
 *
 * @requires $stateProvider
 *
 * @description
 *   State routes defined for the errata module.
 */
angular.module('Bastion.errata').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('errata', {
        abstract: true,
        controller: 'ErrataController',
        templateUrl: 'errata/views/errata.html'
    })
    .state('errata.index', {
        url: '/errata?repositoryId',
        permission: ['view_products', 'view_content_views'],
        views: {
            'table': {
                templateUrl: 'errata/views/errata-table-full.html'
            }
        }
    })

    .state('errata.apply', {
        url: '/errata/apply',
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'errata/views/errata-table-collapsed.html'
            },
            'action-panel': {
                templateUrl: 'errata/views/apply-errata.html'
            }
        }
    })
    .state('errata.apply.select-content-hosts', {
        url: '/select-content-hosts',
        collapsed: true,
        permission: 'edit_content_hosts',
        controller: 'ErrataContentHostsController',
        templateUrl: 'errata/views/apply-errata-select-content-hosts.html'
    })
    .state('errata.apply.confirm', {
        url: '/confirm',
        collapsed: true,
        permission: 'edit_content_hosts',
        controller: 'ApplyErrataController',
        templateUrl: 'errata/views/apply-errata-confirm.html'
    })

    .state('errata.details', {
        abstract: true,
        url: '/errata/:errataId',
        permission: ['view_products', 'view_content_views'],
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'errata/views/errata-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ErrataDetailsController',
                templateUrl: 'errata/details/views/errata-details.html'
            }
        }
    })
    .state('errata.details.apply', {
        url: '/apply',
        collapsed: true,
        permission: 'edit_content_hosts',
        controller: 'ApplyErrataController',
        templateUrl: 'errata/views/apply-errata-confirm.html'
    })
    .state('errata.details.info', {
        url: '/info',
        collapsed: true,
        permission:  ['view_products', 'view_content_views'],
        templateUrl: 'errata/details/views/errata-details-info.html'
    })
    .state('errata.details.content-hosts', {
        url: '/content-hosts',
        collapsed: true,
        permission:  ['view_products', 'view_content_views'],
        controller: 'ErrataContentHostsController',
        templateUrl: 'errata/details/views/errata-details-content-hosts.html'
    })
    .state('errata.details.repositories', {
        url: '/repositories',
        collapsed: true,
        permission:  ['view_products', 'view_content_views'],
        controller: 'ErrataDetailsRepositoriesController',
        templateUrl: 'errata/details/views/errata-details-repositories.html'
    });
}]);
