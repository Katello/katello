(function () {
    'use strict';

    /**
     * @ngdoc object
     * @name Bastion.debs.config
     *
     * @requires $stateProvider
     *
     * @description
     *   State routes defined for the debs module
     */
    function DebsConfig($stateProvider) {
        $stateProvider.state('debs', {
            url: '/debs',
            permission: ['view_products', 'view_content_views'],
            views: {
                '@': {
                    controller: 'DebsController',
                    templateUrl: 'debs/views/debs.html'
                }
            },
            ncyBreadcrumb: {
                label: "{{ 'Debs' | translate }}"
            }
        })
        .state('deb', {
            abstract: true,
            url: '/debs/:debId',
            permission: ['view_products', 'view_content_views'],
            controller: 'DebController',
            templateUrl: 'debs/details/views/deb.html'
        })
        .state('deb.info', {
            url: '',
            permission: ['view_products', 'view_content_views'],
            templateUrl: 'debs/details/views/deb-info.html',
            ncyBreadcrumb: {
                label: "{{ deb.name }}",
                parent: 'debs'
            }
        })
        .state('deb.repositories', {
            url: '/repositories',
            permission: ['view_products'],
            controller: 'DebRepositoriesController',
            templateUrl: 'debs/details/views/deb-repositories.html',
            ncyBreadcrumb: {
                label: "{{ 'Repositories' | translate }}",
                parent: 'deb.info'
            }
        })
        .state('deb.content-views', {
            url: '/content_views',
            collapsed: true,
            permission: ['view_content_views'],
            controller: 'DebContentViewsController',
            templateUrl: 'debs/details/views/deb-content-views.html',
            ncyBreadcrumb: {
                label: "{{ 'Content Views' | translate }}",
                parent: 'deb.info'
            }
        });
    }

    angular
        .module('Bastion.debs')
        .config(DebsConfig);

    DebsConfig.$inject = ['$stateProvider'];
})();
