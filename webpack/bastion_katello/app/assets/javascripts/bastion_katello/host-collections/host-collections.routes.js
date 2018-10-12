angular.module('Bastion.host-collections').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('host-collections', {
        url: '/host_collections',
        permission: 'view_host_collections',
        template: '<div ui-view></div>',
        views: {
            '@': {
                controller: 'HostCollectionsController',
                templateUrl: 'host-collections/views/host-collections.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Host Collections' | translate }}"
        }
    })
    .state('host-collections.new', {
        url: '/new',
        permission: 'create_host_collections',
        views: {
            '@': {
                controller: 'NewHostCollectionController',
                templateUrl: 'host-collections/new/views/new-host-collection.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'New Host Collection' | translate }}"
        }
    });

    $stateProvider.state("host-collection", {
        abstract: true,
        url: '/host_collections/:hostCollectionId',
        permission: 'view_host_collections',
        controller: 'HostCollectionDetailsController',
        templateUrl: 'host-collections/details/views/host-collection-details.html'
    })
    .state('host-collection.info', {
        url: '',
        permission: 'view_host_collections',
        templateUrl: 'host-collections/details/views/host-collection-info.html',
        ncyBreadcrumb: {
            label: "{{ hostCollection.name }}",
            parent: 'host-collections'
        }
    })
    .state('host-collection.hosts', {
        abstract: true,
        templateUrl: 'host-collections/details/views/host-collection-hosts.html'
    })
    .state('host-collection.hosts.list', {
        url: '/hosts',
        permission: 'view_host_collections',
        controller: 'HostCollectionHostsController',
        templateUrl: 'host-collections/details/views/host-collection-hosts-list.html',
        ncyBreadcrumb: {
            label: "{{ 'List Hosts' | translate }}",
            parent: 'host-collection.info'
        }
    })
    .state('host-collection.hosts.add', {
        url: '/add-hosts',
        permission: 'edit_host_collections',
        controller: 'HostCollectionAddHostsController',
        templateUrl: 'host-collections/details/views/host-collection-add-hosts.html',
        ncyBreadcrumb: {
            label: "{{ 'List Hosts' | translate }}",
            parent: 'host-collection.info'
        }
    })
    .state('host-collection.copy', {
        url: '/copy',
        permission: 'create_host_collections',
        controller: 'HostCollectionCopyController',
        templateUrl: 'host-collections/details/views/host-collection-copy.html',
        ncyBreadcrumb: {
            label: "{{ 'Create Copy' | translate }}",
            parent: 'host-collection.info'
        }
    });
}]);
