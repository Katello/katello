(function () {
    'use strict';

    /**
     * @ngdoc object
     * @name Bastion.puppet-modules.config
     *
     * @requires $stateProvider
     *
     * @description
     *   State routes defined for the docker tags module.
     */
    function PuppetModulesConfig($stateProvider) {
        $stateProvider.state('puppet-modules', {
            url: '/puppet_modules',
            permission: ['view_products', 'view_content_views'],
            views: {
                '@': {
                    controller: 'PuppetModulesController',
                    templateUrl: 'puppet-modules/views/puppet-modules.html'
                }
            },
            ncyBreadcrumb: {
                label: "{{ 'Puppet Modules' | translate }}"
            }
        })
        .state('puppet-module', {
            abstract: true,
            url: '/puppet_modules/:puppetModuleId',
            permission: ['view_products', 'view_content_views'],
            controller: 'PuppetModuleController',
            templateUrl: 'puppet-modules/details/views/puppet-module.html'
        })
        .state('puppet-module.info', {
            url: '',
            permission: ['view_products', 'view_content_views'],
            templateUrl: 'puppet-modules/details/views/puppet-module-info.html',
            ncyBreadcrumb: {
                label: "{{ puppetModule.name }}",
                parent: 'puppet-modules'
            }
        })
        .state('puppet-module.repositories', {
            url: '/repositories',
            permission: ['view_products'],
            controller: 'PuppetModuleRepositoriesController',
            templateUrl: 'puppet-modules/details/views/puppet-module-repositories.html',
            ncyBreadcrumb: {
                label: "{{ 'Repositories' | translate }}",
                parent: 'puppet-module.info'
            }
        })
        .state('puppet-module.content-views', {
            url: '/content_views',
            collapsed: true,
            permission: ['view_content_views'],
            controller: 'PuppetModuleContentViewsController',
            templateUrl: 'puppet-modules/details/views/puppet-module-content-views.html',
            ncyBreadcrumb: {
                label: "{{ 'Content Views' | translate }}",
                parent: 'puppet-module.info'
            }
        });
    }

    angular
        .module('Bastion.puppet-modules')
        .config(PuppetModulesConfig);

    PuppetModulesConfig.$inject = ['$stateProvider'];
})();
