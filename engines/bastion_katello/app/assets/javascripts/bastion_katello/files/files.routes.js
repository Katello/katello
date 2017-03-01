(function () {
    'use strict';

    /**
     * @ngdoc object
     * @name Bastion.files.config
     *
     * @requires $stateProvider
     *
     * @description
     *   State routes defined for the files module
     */
    function FilesConfig($stateProvider) {
        $stateProvider.state('files', {
            url: '/files',
            permission: ['view_products', 'view_content_views'],
            views: {
                '@': {
                    controller: 'FilesController',
                    templateUrl: 'files/views/files.html'
                }
            },
            ncyBreadcrumb: {
                label: "{{ 'Files' | translate }}"
            }
        })
        .state('file', {
            abstract: true,
            url: '/files/:fileId',
            permission: ['view_products', 'view_content_views'],
            controller: 'FileController',
            templateUrl: 'files/details/views/file.html'
        })
        .state('file.info', {
            url: '',
            permission: ['view_products', 'view_content_views'],
            templateUrl: 'files/details/views/file-info.html',
            ncyBreadcrumb: {
                label: "{{ file.name }}",
                parent: 'files'
            }
        })
        .state('file.repositories', {
            url: '/repositories',
            permission: ['view_products'],
            controller: 'FileRepositoriesController',
            templateUrl: 'files/details/views/file-repositories.html',
            ncyBreadcrumb: {
                label: "{{ 'Repositories' | translate }}",
                parent: 'file.info'
            }
        })
        .state('file.content-views', {
            url: '/content_views',
            collapsed: true,
            permission: ['view_content_views'],
            controller: 'FileContentViewsController',
            templateUrl: 'files/details/views/file-content-views.html',
            ncyBreadcrumb: {
                label: "{{ 'Content Views' | translate }}",
                parent: 'file.info'
            }
        });
    }

    angular
        .module('Bastion.files')
        .config(FilesConfig);

    FilesConfig.$inject = ['$stateProvider'];
})();
