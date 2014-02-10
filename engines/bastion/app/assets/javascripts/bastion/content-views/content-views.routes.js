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
 * @name Bastion.content-views.config
 *
 * @requires $stateProvider
 *
 * @description
 *   State routes defined for the content views module.
 */
angular.module('Bastion.content-views').config(['$stateProvider', function ($stateProvider) {
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

    .state('content-views.new', {
        collapsed: true,
        url: '/content_views/new',
        views: {
            'table': {
                templateUrl: 'content-views/views/content-views-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NewContentViewController',
                templateUrl: 'content-views/new/views/content-view-new.html'
            }
        }
    })

    .state('content-views.details', {
        abstract: true,
        url: '/content_views/:contentViewId',
        views: {
            'table': {
                templateUrl: 'content-views/views/content-views-table-collapsed.html'
            },
            'action-panel': {
                controller: 'ContentViewDetailsController',
                templateUrl: 'content-views/details/views/content-view-details.html'
            }
        }
    })
    .state('content-views.details.versions', {
        collapsed: true,
        url: '/versions',
        controller: 'ContentViewVersionsController',
        templateUrl: 'content-views/details/views/content-view-versions.html'
    })
    .state('content-views.details.promotion', {
        collapsed: true,
        url: '/versions/:versionId/promotion',
        controller: 'ContentViewPromotionController',
        templateUrl: 'content-views/details/views/content-view-promotion.html'
    })
    .state('content-views.details.repositories', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('content-views.details.repositories.list', {
        collapsed: true,
        url: '/repositories',
        controller: 'ContentViewRepositoriesListController',
        templateUrl: 'content-views/details/views/content-view-repositories.html'
    })
    .state('content-views.details.repositories.available', {
        collapsed: true,
        url: '/repositories/available',
        controller: 'ContentViewAvailableRepositoriesController',
        templateUrl: 'content-views/details/views/content-view-repositories.html'
    })

    .state('content-views.details.puppet-modules', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('content-views.details.puppet-modules.list', {
        collapsed: true,
        url: '/puppet_modules/list',
        controller: 'ContentViewPuppetModulesListController',
        templateUrl: 'content-views/details/views/content-view-puppet-modules.html'
    })
    .state('content-views.details.puppet-modules.available', {
        collapsed: true,
        url: '/puppet_modules/available',
        controller: 'ContentViewAvailablePuppetModulesController',
        templateUrl: 'content-views/details/views/content-view-puppet-modules.html'
    })

    .state('content-views.details.info', {
        collapsed: true,
        url: '/info',
        templateUrl: 'content-views/details/views/content-view-info.html'
    })
    .state('content-views.details.publish', {
        collapsed: true,
        url: '/publish',
        controller: 'ContentViewPublishController',
        templateUrl: 'content-views/details/views/content-view-publish.html'
    })

    .state('content-views.details.filters', {
        abstract: true,
        collapsed: true,
        controller: 'FiltersController',
        template: '<div ui-view></div>'
    })
    .state('content-views.details.filters.list', {
        collapsed: true,
        url: '/filters',
        templateUrl: 'content-views/details/filters/views/filters.html'
    })
    .state('content-views.details.filters.new', {
        collapsed: true,
        url: '/filters/new',
        controller: 'NewFilterController',
        templateUrl: 'content-views/details/filters/views/new-filter.html'
    })
    .state('content-views.details.filters.details', {
        abstract: true,
        collapsed: true,
        controller: 'FilterDetailsController',
        templateUrl: 'content-views/details/filters/views/filter-details.html'
    })
    .state('content-views.details.filters.details.rpm', {
        collapsed: true,
        url: '/filters/:filterId/packages',
        controller: 'PackageFilterController',
        templateUrl: 'content-views/details/filters/views/package-filter.html'
    })
    .state('content-views.details.filters.details.package_group', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('content-views.details.filters.details.package_group.list', {
        collapsed: true,
        url: '/filters/:filterId/package_groups/list',
        controller: 'PackageGroupFilterListController',
        templateUrl: 'content-views/details/filters/views/package-group-filter.html'
    })
    .state('content-views.details.filters.details.package_group.available', {
        collapsed: true,
        url: '/filters/:filterId/package_groups/available',
        controller: 'AvailablePackageGroupFilterController',
        templateUrl: 'content-views/details/filters/views/package-group-filter.html'
    })
    .state('content-views.details.filters.details.erratum', {
        abstract: true,
        collapsed: true,
        controller: 'ErrataFilterController',
        templateUrl: 'content-views/details/filters/views/errata-filter.html'
    })
    .state('content-views.details.filters.details.erratum.list', {
        collapsed: true,
        url: '/filters/:filterId/errata/list',
        controller: 'ErrataFilterListController',
        templateUrl: 'content-views/details/filters/views/errata-filter-table.html'
    })
    .state('content-views.details.filters.details.erratum.available', {
        collapsed: true,
        url: '/filters/:filterId/errata/available',
        controller: 'AvailableErrataFilterController',
        templateUrl: 'content-views/details/filters/views/errata-filter-table.html'
    })
    .state('content-views.details.filters.details.erratum.dateType', {
        collapsed: true,
        url: '/filters/:filterId/errata/date_type',
        controller: 'DateTypeErrataFilterController',
        templateUrl: 'content-views/details/filters/views/date-type-errata-filter.html'
    });

}]);
