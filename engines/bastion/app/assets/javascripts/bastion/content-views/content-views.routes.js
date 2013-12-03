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
 * @ngdoc object
 * @name Bastion.content-views.config
 *
 * @requires $stateProvider
 *
 * @description
 *   State routes defined for the content views module.
 */
angular.module('Bastion.content-views').config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('content-views', {
        abstract: true,
        controller: 'ContentViewsController',
        templateUrl: 'content-views/views/content-views.html'
    })
    .state('content-views.index', {
        url: '/content_views',
        views: {
            'table': {
                templateUrl: 'content-views/views/content-views-table-full.html'
            }
        }
    })

    .state('content-views-new', {
        url: '/content_views/new',
        controller: 'NewContentViewController',
        templateUrl: 'content-views/new/views/content-view-new.html'
    })

    .state('content-views-details', {
        abstract: true,
        url: '/content_views/:contentViewId',
        controller: 'ContentViewDetailsController',
        templateUrl: 'content-views/details/views/content-view-details.html'
    })
    .state('content-views-details.versions', {
        url: '/versions',
        controller: 'ContentViewVersionsController',
        templateUrl: 'content-views/details/views/content-view-details-versions.html'
    })
    .state('content-views-details.promotion', {
        url: '/versions/:versionId/promotion',
        controller: 'ContentViewPromotionController',
        templateUrl: 'content-views/details/views/content-view-promotion.html'
    })
    .state('content-views-details.products', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-views-details.products.list', {
        url: '/products',
        controller: 'ContentViewProductsController',
        templateUrl: 'content-views/details/views/content-view-details-products.html'
    })
    .state('content-views-details.products.available', {
        url: '/products/available',
        controller: 'ContentViewAvailableProductsController',
        templateUrl: 'content-views/details/views/content-view-details-products.html'
    })
    .state('content-views-details.puppet-modules', {
        url: '/puppet_modules',
        controller: 'ContentViewPuppetModulesController',
        templateUrl: 'content-views/details/views/content-view-details-puppet-modules.html'
    })
    .state('content-views-details.info', {
        controller: 'ContentViewInfoController',
        templateUrl: 'content-views/details/views/content-view-details-info.html'
    })
    .state('content-views-details.publish', {
        url: '/publish',
        controller: 'ContentViewPublishController',
        templateUrl: 'content-views/details/views/content-view-details-publish.html'
    })

    .state('content-views-details.filters', {
        abstract: true,
        controller: 'ContentViewFiltersController',
        template: '<div ui-view></div>'
    })
    .state('content-views-details.filters.list', {
        url: '/filters',
        templateUrl: 'content-views/details/filters/views/content-view-details-filters.html'
    })
    .state('content-views-details.filters.new', {
        url: '/filters/new',
        controller: 'ContentViewFiltersNewController',
        templateUrl: 'content-views/details/filters/views/content-view-details-filters-new.html'
    })
    .state('content-views-details.filters.details', {
        abstract: true,
        controller: 'ContentViewFilterDetailsController',
        templateUrl: 'content-views/details/filters/views/content-view-filter-details.html'
    })
    .state('content-views-details.filters.details.packages', {
        url: '/filters/:filterId/packages',
        controller: 'ContentViewFilterDetailsPackageController',
        templateUrl: 'content-views/details/filters/views/content-view-filter-details-packages.html'
    })
    .state('content-views-details.filters.details.errata', {
        url: '/filters/:filterId/errata',
        controller: 'ContentViewFilterDetailsErrataController',
        templateUrl: 'content-views/details/filters/views/content-view-filter-details-errata.html'
    })

}]);
