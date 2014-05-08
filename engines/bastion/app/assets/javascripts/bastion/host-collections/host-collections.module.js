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
 * @ngdoc module
 * @name  Bastion.host-collections
 *
 * @description
 *   Module for host collections related functionality.
 */
angular.module('Bastion.host-collections', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.utils'
]);

angular.module('Bastion.host-collections').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('host-collections', {
        abstract: true,
        controller: 'HostCollectionsController',
        templateUrl: 'host-collections/views/host-collections.html'
    })
    .state('host-collections.index', {
        url: '/host_collections',
        views: {
            'table': {
                templateUrl: 'host-collections/views/host-collections-table-full.html'
            }
        }
    })
    .state('host-collections.new', {
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'host-collections/views/host-collections-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NewHostCollectionController',
                templateUrl: 'host-collections/new/views/host-collection-new.html'
            }
        }
    })
    .state('host-collections.new.form', {
        url: '/host_collections/new',
        collapsed: true,
        controller: 'HostCollectionFormController',
        templateUrl: 'host-collections/new/views/host-collection-new-form.html'
    });

    $stateProvider.state("host-collections.details", {
        abstract: true,
        url: '/host_collections/:hostCollectionId',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'host-collections/views/host-collections-table-collapsed.html'
            },
            'action-panel': {
                controller: 'HostCollectionDetailsController',
                templateUrl: 'host-collections/details/views/host-collection-details.html'
            }
        }
    })
    .state('host-collections.details.info', {
        url: '/info',
        collapsed: true,
        controller: 'HostCollectionDetailsInfoController',
        templateUrl: 'host-collections/details/views/host-collection-info.html'
    })
    .state('host-collections.details.content-hosts', {
        abstract: true,
        collapsed: true,
        templateUrl: 'host-collections/details/views/host-collection-content-hosts.html'
    })
    .state('host-collections.details.content-hosts.list', {
        url: '/content-hosts',
        collapsed: true,
        controller: 'HostCollectionContentHostsController',
        templateUrl: 'host-collections/details/views/host-collection-content-hosts-list.html'
    })
    .state('host-collections.details.content-hosts.add', {
        url: '/add-content-hosts',
        collapsed: true,
        controller: 'HostCollectionAddContentHostsController',
        templateUrl: 'host-collections/details/views/host-collection-add-content-hosts.html'
    })
    .state('host-collections.details.actions', {
        url: '/actions',
        collapsed: true,
        templateUrl: 'host-collections/details/views/host-collection-actions.html'
    });



}]);
