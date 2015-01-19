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
        permission: 'view_content_views',
        views: {
            'table': {
                templateUrl: 'content-views/views/content-views-table-full.html'
            }
        }
    })

    .state('content-views.new', {
        collapsed: true,
        url: '/content_views/new',
        permission: 'create_content_views',
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
        permission: 'view_content_views',
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
        permission: 'view_content_views',
        controller: 'ContentViewVersionsController',
        templateUrl: 'content-views/details/views/content-view-versions.html'
    })
    .state('content-views.details.version', {
        collapsed: true,
        abstract: true,
        url: '/versions/:versionId',
        controller: 'ContentViewVersionController',
        templateUrl: 'content-views/versions/views/content-view-version.html'
    })
    .state('content-views.details.version.details', {
        collapsed: true,
        url: '/details',
        permission: 'view_content_views',
        templateUrl: 'content-views/versions/views/content-view-version-details.html'
    })
    .state('content-views.details.version.components', {
        collapsed: true,
        url: '/components',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-components.html'
    })
    .state('content-views.details.version.yum', {
        collapsed: true,
        url: '/yum',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-yum.html'
    })
    .state('content-views.details.version.docker', {
        collapsed: true,
        url: '/docker',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-docker.html'
    })
    .state('content-views.details.version.packages', {
        collapsed: true,
        url: '/packages',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-packages.html'
    })
    .state('content-views.details.version.package-groups', {
        collapsed: true,
        url: '/package_groups',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-package-groups.html'
    })
    .state('content-views.details.version.errata', {
        collapsed: true,
        url: '/errata',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-errata.html'
    })
    .state('content-views.details.version.puppet-modules', {
        collapsed: true,
        url: '/puppet_modules',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-puppet-modules.html'
    })

    .state('content-views.details.promotion', {
        collapsed: true,
        url: '/versions/:versionId/promotion',
        permission: 'promote_or_remove_content_views',
        controller: 'ContentViewPromotionController',
        templateUrl: 'content-views/details/views/content-view-promotion.html'
    })
    .state('content-views.details.version-deletion', {
        collapsed: true,
        abstract: true,
        controller: 'ContentViewVersionDeletionController',
        template: '<div ui-view></div>'
    })
    .state('content-views.details.version-deletion.environments', {
        collapsed: true,
        url: '/versions/:versionId/delete/environments',
        permission: 'promote_or_remove_content_views',
        controller: 'ContentViewVersionDeletionEnvironmentsController',
        templateUrl: 'content-views/deletion/views/version-deletion-environments.html'
    })
    .state('content-views.details.version-deletion.content-hosts', {
        url: '/versions/:versionId/delete/content-hosts',
        permission: 'promote_or_remove_content_views',
        collapsed: true,
        controller: 'ContentViewVersionDeletionContentHostsController',
        templateUrl: 'content-views/deletion/views/version-deletion-content-hosts.html'
    })
    .state('content-views.details.version-deletion.activation-keys', {
        url: '/versions/:versionId/delete/activation-keys',
        permission: 'promote_or_remove_content_views',
        collapsed: true,
        controller: 'ContentViewVersionDeletionActivationKeysController',
        templateUrl: 'content-views/deletion/views/version-deletion-activation-keys.html'
    })
    .state('content-views.details.version-deletion.confirm', {
        url: '/versions/:versionId/delete/confirm',
        permission: 'promote_or_remove_content_views',
        collapsed: true,
        controller: 'ContentViewVersionDeletionConfirmController',
        templateUrl: 'content-views/deletion/views/version-deletion-confirm.html'
    })
    .state('content-views.details.deletion', {
        collapsed: true,
        url: '/delete',
        permission: 'promote_or_remove_content_views',
        controller: 'ContentViewDeletionController',
        templateUrl: 'content-views/deletion/views/content-view-deletion.html'
    })
    .state('content-views.details.repositories', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('content-views.details.repositories.yum', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('content-views.details.repositories.yum.list', {
        collapsed: true,
        url: '/repositories/yum',
        permission: 'view_content_views',
        controller: 'ContentViewRepositoriesListController',
        templateUrl: 'content-views/details/views/content-view-repositories.html'
    })
    .state('content-views.details.repositories.yum.available', {
        collapsed: true,
        url: '/repositories/yum/available',
        permission: 'view_content_views',
        controller: 'ContentViewAvailableRepositoriesController',
        templateUrl: 'content-views/details/views/content-view-repositories.html'
    })
    .state('content-views.details.repositories.docker', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('content-views.details.repositories.docker.list', {
        collapsed: true,
        url: '/repositories/docker',
        permission: 'view_content_views',
        controller: 'ContentViewDockerRepositoriesListController',
        templateUrl: 'content-views/details/views/content-view-docker-repositories.html'
    })
    .state('content-views.details.repositories.docker.available', {
        collapsed: true,
        url: '/repositories/docker/available',
        permission: 'view_content_views',
        controller: 'ContentViewAvailableDockerRepositoriesController',
        templateUrl: 'content-views/details/views/content-view-docker-repositories.html'
    })
    .state('content-views.details.history', {
        collapsed: true,
        url: '/history',
        permission: 'view_content_views',
        controller: 'ContentViewHistoryController',
        templateUrl: 'content-views/details/views/content-view-details-history.html'
    })
    .state('content-views.details.composite-content-views', {
        abstract: true,
        collapsed: true,
        templateUrl: 'content-views/details/views/content-view-composite.html'
    })
    .state('content-views.details.composite-content-views.list', {
        collapsed: true,
        url: '/content-views',
        permission: 'view_content_views',
        controller: 'ContentViewCompositeContentViewsListController',
        templateUrl: 'content-views/details/views/content-view-composite-content-views-list.html'
    })
    .state('content-views.details.composite-content-views.available', {
        collapsed: true,
        url: '/content-views/available',
        permission: 'edit_content_views',
        controller: 'ContentViewCompositeAvailableContentViewsController',
        templateUrl: 'content-views/details/views/content-view-composite-available-content-views.html'
    })
    .state('content-views.details.puppet-modules', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('content-views.details.puppet-modules.list', {
        collapsed: true,
        url: '/puppet_modules',
        permission: 'view_content_views',
        controller: 'ContentViewPuppetModulesController',
        templateUrl: 'content-views/details/puppet-modules/views/content-view-puppet-modules.html'
    })
    .state('content-views.details.puppet-modules.names', {
        collapsed: true,
        url: '/puppet_modules/names',
        permission: 'edit_content_views',
        controller: 'ContentViewPuppetModuleNamesController',
        templateUrl: 'content-views/details/puppet-modules/views/content-view-puppet-module-names.html'
    })
    .state('content-views.details.puppet-modules.versions', {
        collapsed: true,
        url: '/puppet_modules/:moduleName/versions',
        permission: 'edit_content_views',
        controller: 'ContentViewPuppetModuleVersionsController',
        templateUrl: 'content-views/details/puppet-modules/views/content-view-puppet-module-versions.html'
    })
    // Necessary until ui-router supports optional parameters, see https://github.com/angular-ui/ui-router/issues/108
    .state('content-views.details.puppet-modules.versionsForModule', {
        collapsed: true,
        url: '/puppet_modules/:moduleName/versions/:moduleId',
        permission: 'edit_content_views',
        controller: 'ContentViewPuppetModuleVersionsController',
        templateUrl: 'content-views/details/puppet-modules/views/content-view-puppet-module-versions.html'
    })
    .state('content-views.details.info', {
        collapsed: true,
        url: '/info',
        permission: 'view_content_views',
        templateUrl: 'content-views/details/views/content-view-info.html'
    })
    .state('content-views.details.publish', {
        collapsed: true,
        url: '/publish',
        permission: 'publish_content_views',
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
        permission: 'view_content_views',
        templateUrl: 'content-views/details/filters/views/filters.html'
    })
    .state('content-views.details.filters.new', {
        collapsed: true,
        url: '/filters/new',
        permission: 'edit_content_views',
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
        abstract: true,
        collapsed: true,
        url: '/filters/:filterId/package',
        permission: 'view_content_views',
        controller: 'PackageFilterController',
        templateUrl: 'content-views/details/filters/views/package-filter.html'
    })
    .state('content-views.details.filters.details.rpm.details', {
        url: '/details',
        permission: 'view_content_views',
        collapsed: true,
        controller: 'PackageFilterController',
        templateUrl: 'content-views/details/filters/views/package-filter-details.html'
    })
    .state('content-views.details.filters.details.rpm.edit', {
        url: '/edit',
        collapsed: true,
        controller: 'FilterEditController',
        permission: 'edit_content_views',
        templateUrl: 'content-views/details/filters/views/edit-filter.html'
    })
    .state('content-views.details.filters.details.rpm.repositories', {
        collapsed: true,
        url: '/repositories',
        permission: 'view_content_views',
        controller: 'FilterRepositoriesController',
        templateUrl: 'content-views/details/filters/views/filter-repositories.html'
    })

    .state('content-views.details.filters.details.package_group', {
        abstract: true,
        collapsed: true,
        controller: 'PackageGroupFilterController',
        url: '/filters/:filterId/package-group',
        templateUrl: 'content-views/details/filters/views/package-group-filter.html'
    })
    .state('content-views.details.filters.details.package_group.edit', {
        url: '/edit',
        collapsed: true,
        controller: 'FilterEditController',
        permission: 'edit_content_views',
        templateUrl: 'content-views/details/filters/views/edit-filter.html'
    })
    .state('content-views.details.filters.details.package_group.list', {
        collapsed: true,
        url: '/list',
        permission: 'view_content_views',
        controller: 'PackageGroupFilterListController',
        templateUrl: 'content-views/details/filters/views/package-group-filter-details.html'
    })
    .state('content-views.details.filters.details.package_group.available', {
        collapsed: true,
        url: '/available',
        permission: 'edit_content_views',
        controller: 'AvailablePackageGroupFilterController',
        templateUrl: 'content-views/details/filters/views/package-group-filter-details.html'
    })
    .state('content-views.details.filters.details.package_group.repositories', {
        collapsed: true,
        url: '/repositories',
        permission: 'view_content_views',
        controller: 'FilterRepositoriesController',
        templateUrl: 'content-views/details/filters/views/filter-repositories.html'
    })

    .state('content-views.details.filters.details.erratum', {
        abstract: true,
        collapsed: true,
        url: '/filters/:filterId/errata',
        controller: 'ErrataFilterController',
        templateUrl: 'content-views/details/filters/views/errata-filter.html'
    })
    .state('content-views.details.filters.details.erratum.edit', {
        url: '/edit',
        collapsed: true,
        controller: 'FilterEditController',
        permission: 'edit_content_views',
        templateUrl: 'content-views/details/filters/views/edit-filter.html'
    })
    .state('content-views.details.filters.details.erratum.list', {
        collapsed: true,
        url: '/list',
        permission: 'view_content_views',
        controller: 'ErrataFilterListController',
        templateUrl: 'content-views/details/filters/views/errata-filter-details.html'
    })
    .state('content-views.details.filters.details.erratum.available', {
        collapsed: true,
        url: '/available',
        permission: 'edit_content_views',
        controller: 'AvailableErrataFilterController',
        templateUrl: 'content-views/details/filters/views/errata-filter-details.html'
    })
    .state('content-views.details.filters.details.erratum.dateType', {
        collapsed: true,
        url: '/date_type',
        permission: 'view_content_views',
        controller: 'DateTypeErrataFilterController',
        templateUrl: 'content-views/details/filters/views/date-type-errata-filter.html'
    })
    .state('content-views.details.filters.details.erratum.repositories', {
        collapsed: true,
        url: '/repositories',
        permission: 'view_content_views',
        controller: 'FilterRepositoriesController',
        templateUrl: 'content-views/details/filters/views/filter-repositories.html'
    })

    .state('content-views.details.tasks', {
        abstract: true,
        collapsed: true,
        template: '<div ui-view></div>'
    })
    .state('content-views.details.tasks.index', {
        url: '/tasks',
        permission: 'view_content_views',
        collapsed: true,
        templateUrl: 'content-views/details/views/content-view-details-tasks.html'
    })
    .state('content-views.details.tasks.details', {
        url: '/tasks/:taskId',
        permission: 'view_content_views',
        collapsed: true,
        controller: 'TaskDetailsController',
        templateUrl: 'tasks/views/task-details.html'
    });
}]);
