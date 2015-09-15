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
            abstract: true,
            controller: 'PuppetModulesController',
            templateUrl: 'puppet-modules/views/puppet-modules.html'
        })
        .state('puppet-modules.index', {
            url: '/puppet_modules',
            permission: ['view_products', 'view_content_views'],
            views: {
                'table': {
                    templateUrl: 'puppet-modules/views/puppet-modules-table-full.html'
                }
            }
        })
        .state('puppet-modules.details', {
            url: '/puppet_modules/:puppetModuleId',
            permission: ['view_products', 'view_content_views'],
            collapsed: true,
            views: {
                'table': {
                    templateUrl: 'puppet-modules/views/puppet-modules-table-collapsed.html'
                },
                'action-panel': {
                    controller: 'PuppetModulesDetailsController',
                    templateUrl: 'puppet-modules/details/views/puppet-modules-details.html'
                }
            }
        })
        .state('puppet-modules.details.info', {
            url: '/info',
            collapsed: true,
            permission: ['view_products', 'view_content_views'],
            templateUrl: 'puppet-modules/details/views/puppet-modules-details-info.html'
        })
        .state('puppet-modules.details.repositories', {
            url: '/repositories',
            collapsed: true,
            permission: ['view_products'],
            controller: 'PuppetModulesDetailsRepositoriesController',
            templateUrl: 'puppet-modules/details/views/puppet-modules-details-repositories.html'
        })
        .state('puppet-modules.details.content-views', {
            url: '/content_views',
            collapsed: true,
            permission: ['view_content_views'],
            controller: 'PuppetModulesDetailsContentViewsController',
            templateUrl: 'puppet-modules/details/views/puppet-modules-details-content-views.html'
        });
    }

    angular
        .module('Bastion.puppet-modules')
        .config(PuppetModulesConfig);

    PuppetModulesConfig.$inject = ['$stateProvider'];
})();
