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
        permission: 'view_host_collections',
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
        permission: 'create_host_collections',
        collapsed: true,
        controller: 'HostCollectionFormController',
        templateUrl: 'host-collections/new/views/host-collection-new-form.html'
    });

    $stateProvider.state("host-collections.details", {
        abstract: true,
        url: '/host_collections/:hostCollectionId',
        permission: 'view_host_collections',
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
        permission: 'view_host_collections',
        collapsed: true,
        templateUrl: 'host-collections/details/views/host-collection-info.html'
    })
    .state('host-collections.details.hosts', {
        abstract: true,
        collapsed: true,
        templateUrl: 'host-collections/details/views/host-collection-hosts.html'
    })
    .state('host-collections.details.hosts.list', {
        url: '/hosts',
        permission: 'view_host_collections',
        collapsed: true,
        controller: 'HostCollectionHostsController',
        templateUrl: 'host-collections/details/views/host-collection-hosts-list.html'
    })
    .state('host-collections.details.hosts.add', {
        url: '/add-hosts',
        permission: 'edit_host_collections',
        collapsed: true,
        controller: 'HostCollectionAddHostsController',
        templateUrl: 'host-collections/details/views/host-collection-add-hosts.html'
    })
    .state('host-collections.details.actions', {
        url: '/actions',
        permission: 'edit_host_collections',
        collapsed: true,
        templateUrl: 'host-collections/details/views/host-collection-actions.html'
    });

}]);
