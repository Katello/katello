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
        url: '/content_views',
        permission: 'view_content_views',
        views: {
            '@': {
                controller: 'ContentViewsController',
                templateUrl: 'content-views/views/content-views.html'
            }
        },
        ncyBreadcrumb: {
            label: '{{ "Content Views" | translate }}'
        }
    })
    .state('content-views.new', {
        url: '/new',
        permission: 'create_content_views',
        views: {
            '@': {
                controller: 'NewContentViewController',
                templateUrl: 'content-views/new/views/content-view-new.html'
            }
        },
        ncyBreadcrumb: {
            label: '{{ "New Content View" | translate }}',
            parent: 'content-views'
        }
    });

    $stateProvider.state('content-view', {
        abstract: true,
        url: '/content_views/:contentViewId',
        permission: 'view_content_views',
        controller: 'ContentViewDetailsController',
        templateUrl: 'content-views/details/views/content-view-details.html'
    })

    .state('content-view.versions', {
        url: '/versions',
        permission: 'view_content_views',
        controller: 'ContentViewVersionsController',
        templateUrl: 'content-views/details/views/content-view-versions.html',
        ncyBreadcrumb: {
            label: '{{ "Versions" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.version', {
        abstract: true,
        url: '/versions/:versionId',
        controller: 'ContentViewVersionController',
        templateUrl: 'content-views/versions/views/content-view-version.html'
    })
    .state('content-view.version.details', {
        url: '',
        permission: 'view_content_views',
        controller: 'ContentViewVersionController',
        templateUrl: 'content-views/versions/views/content-view-version-details.html',
        ncyBreadcrumb: {
            label: '{{ version.name }}',
            parent: 'content-view.versions'
        }
    })
    .state('content-view.version.components', {
        url: '/components',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-components.html',
        ncyBreadcrumb: {
            label: '{{ "Components" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.yum', {
        url: '/yum',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-yum.html',
        ncyBreadcrumb: {
            label: '{{ "Yum Content" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.docker', {
        url: '/docker',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-docker.html',
        ncyBreadcrumb: {
            label: '{{ "Docker" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.packages', {
        url: '/packages',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-packages.html',
        ncyBreadcrumb: {
            label: '{{ "Packages" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.package-groups', {
        url: '/package_groups',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-package-groups.html',
        ncyBreadcrumb: {
            label: '{{ "Package Groups" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.errata', {
        url: '/errata',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-errata.html',
        ncyBreadcrumb: {
            label: '{{ "Errata" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.puppet-modules', {
        url: '/puppet_modules',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-puppet-modules.html',
        ncyBreadcrumb: {
            label: '{{ "Puppet Modules" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.ostree-branches', {
        url: '/ostree_branches',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-ostree-branches.html',
        ncyBreadcrumb: {
            label: '{{ "OSTree Branches" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.module-streams', {
        url: '/module_streams',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-module-streams.html',
        ncyBreadcrumb: {
            label: '{{ "Module Streams" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.file', {
        url: '/file',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-file.html',
        ncyBreadcrumb: {
            label: '{{ "File" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.apt', {
        url: '/apt',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-apt.html',
        ncyBreadcrumb: {
            label: '{{ "Apt Repositories" | translate }}',
            parent: 'content-view.version.details'
        }
    })
    .state('content-view.version.deb', {
        url: '/deb',
        permission: 'view_content_views',
        controller: 'ContentViewVersionContentController',
        templateUrl: 'content-views/versions/views/content-view-version-deb.html',
        ncyBreadcrumb: {
            label: '{{ "Deb" | translate }}',
            parent: 'content-view.version.details'
        }
    });

    $stateProvider.state('content-view.promotion', {
        url: '/versions/:versionId/promotion',
        permission: 'promote_or_remove_content_views',
        controller: 'ContentViewPromotionController',
        templateUrl: 'content-views/details/views/content-view-promotion.html',
        ncyBreadcrumb: {
            label: '{{ "Promotion" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.version-deletion', {
        abstract: true,
        controller: 'ContentViewVersionDeletionController',
        template: '<div ui-view></div>'
    })
    .state('content-view.version-deletion.environments', {
        url: '/versions/:versionId/delete/environments',
        permission: 'promote_or_remove_content_views',
        controller: 'ContentViewVersionDeletionEnvironmentsController',
        templateUrl: 'content-views/deletion/views/version-deletion-environments.html',
        ncyBreadcrumb: {
            label: '{{ "Deletion" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.version-deletion.content-hosts', {
        url: '/versions/:versionId/delete/content-hosts',
        permission: 'promote_or_remove_content_views',
        controller: 'ContentViewVersionDeletionContentHostsController',
        templateUrl: 'content-views/deletion/views/version-deletion-content-hosts.html',
        ncyBreadcrumb: {
            label: '{{ "Deletion" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.version-deletion.activation-keys', {
        url: '/versions/:versionId/delete/activation-keys',
        permission: 'promote_or_remove_content_views',
        controller: 'ContentViewVersionDeletionActivationKeysController',
        templateUrl: 'content-views/deletion/views/version-deletion-activation-keys.html',
        ncyBreadcrumb: {
            label: '{{ "Deletion" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.version-deletion.confirm', {
        url: '/versions/:versionId/delete/confirm',
        permission: 'promote_or_remove_content_views',
        controller: 'ContentViewVersionDeletionConfirmController',
        templateUrl: 'content-views/deletion/views/version-deletion-confirm.html',
        ncyBreadcrumb: {
            label: '{{ "Deletion" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.deletion', {
        url: '/delete',
        permission: 'promote_or_remove_content_views',
        controller: 'ContentViewDeletionController',
        templateUrl: 'content-views/deletion/views/content-view-deletion.html',
        ncyBreadcrumb: {
            label: '{{ "Deletion" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-view.repositories.yum', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-view.repositories.yum.list', {
        url: '/repositories/yum',
        permission: 'view_content_views',
        controller: 'ContentViewRepositoriesListController',
        templateUrl: 'content-views/details/views/content-view-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Yum Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories.yum.available', {
        url: '/repositories/yum/available',
        permission: 'view_content_views',
        controller: 'ContentViewAvailableRepositoriesController',
        templateUrl: 'content-views/details/views/content-view-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Add Yum Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories.file', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-view.repositories.file.list', {
        url: '/repositories/file',
        permission: 'view_content_views',
        controller: 'ContentViewFileRepositoriesListController',
        templateUrl: 'content-views/details/views/content-view-file-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "File Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories.file.available', {
        url: '/repositories/file/available',
        permission: 'view_content_views',
        controller: 'ContentViewAvailableFileRepositoriesController',
        templateUrl: 'content-views/details/views/content-view-file-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Add File Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories.deb', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-view.repositories.deb.list', {
        url: '/repositories/deb',
        permission: 'view_content_views',
        controller: 'ContentViewDebRepositoriesListController',
        templateUrl: 'content-views/details/views/content-view-deb-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Apt Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories.deb.available', {
        url: '/repositories/deb/available',
        permission: 'view_content_views',
        controller: 'ContentViewAvailableDebRepositoriesController',
        templateUrl: 'content-views/details/views/content-view-deb-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Add Apt Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories.docker', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-view.repositories.docker.list', {
        url: '/repositories/docker',
        permission: 'view_content_views',
        controller: 'ContentViewDockerRepositoriesListController',
        templateUrl: 'content-views/details/views/content-view-docker-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Docker Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories.docker.available', {
        url: '/repositories/docker/available',
        permission: 'view_content_views',
        controller: 'ContentViewAvailableDockerRepositoriesController',
        templateUrl: 'content-views/details/views/content-view-docker-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Add Docker Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories.ostree', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-view.repositories.ostree.list', {
        url: '/repositories/ostree',
        permission: 'view_content_views',
        controller: 'ContentViewOstreeRepositoriesListController',
        templateUrl: 'content-views/details/views/content-view-ostree-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "OSTree Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.repositories.ostree.available', {
        url: '/repositories/ostree/available',
        permission: 'view_content_views',
        controller: 'ContentViewAvailableOstreeRepositoriesController',
        templateUrl: 'content-views/details/views/content-view-ostree-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Add OSTree Repositories" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.components', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-view.components.composite-content-views', {
        abstract: true,
        templateUrl: 'content-views/details/components/views/content-view-composite.html'
    })
    .state('content-view.components.composite-content-views.list', {
        url: '/content-views',
        permission: 'view_content_views',
        controller: 'ContentViewCompositeContentViewsListController',
        templateUrl: 'content-views/details/components/views/content-view-composite-content-views-list.html',
        ncyBreadcrumb: {
            label: '{{ "Content Views" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.components.composite-content-views.available', {
        url: '/content-views/available',
        permission: 'edit_content_views',
        controller: 'ContentViewCompositeAvailableContentViewsController',
        templateUrl: 'content-views/details/components/views/content-view-composite-available-content-views.html',
        ncyBreadcrumb: {
            label: '{{ "Add Content Views" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.puppet-modules', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-view.puppet-modules.list', {
        url: '/puppet_modules',
        permission: 'view_content_views',
        controller: 'ContentViewPuppetModulesController',
        templateUrl: 'content-views/details/puppet-modules/views/content-view-puppet-modules.html',
        ncyBreadcrumb: {
            label: '{{ "Puppet Modules" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.puppet-modules.names', {
        url: '/puppet_modules/names',
        permission: 'edit_content_views',
        controller: 'ContentViewPuppetModuleNamesController',
        templateUrl: 'content-views/details/puppet-modules/views/content-view-puppet-module-names.html',
        ncyBreadcrumb: {
            label: '{{ "Add Puppet Module" | translate }}',
            parent: 'content-view.puppet-modules.list'
        }
    })
    .state('content-view.puppet-modules.versions', {
        url: '/puppet_modules/:moduleName/versions',
        permission: 'edit_content_views',
        controller: 'ContentViewPuppetModuleVersionsController',
        templateUrl: 'content-views/details/puppet-modules/views/content-view-puppet-module-versions.html',
        ncyBreadcrumb: {
            label: '{{ "Version for Module:" | translate }} {{ }}',
            parent: 'content-view.puppet-modules.names'
        }
    })
    // Necessary until ui-router supports optional parameters, see https://github.com/angular-ui/ui-router/issues/108
    .state('content-view.puppet-modules.versionsForModule', {
        collapsed: true,
        url: '/puppet_modules/:moduleName/versions/:moduleId',
        permission: 'edit_content_views',
        controller: 'ContentViewPuppetModuleVersionsController',
        templateUrl: 'content-views/details/puppet-modules/views/content-view-puppet-module-versions.html',
        ncyBreadcrumb: {
            label: '{{ "Versions for Module" | translate }}',
            parent: 'content-view.puppet-modules.versions'
        }
    })
    .state('content-view.history', {
        url: '/history',
        permission: 'view_content_views',
        controller: 'ContentViewHistoryController',
        templateUrl: 'content-views/details/histories/views/content-view-history.html',
        ncyBreadcrumb: {
            label: '{{ "History" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.info', {
        url: '',
        permission: 'view_content_views',
        templateUrl: 'content-views/details/views/content-view-info.html',
        ncyBreadcrumb: {
            label: '{{ contentView.name }}',
            parent: 'content-views'
        }
    })
    .state('content-view.copy', {
        url: '/copy',
        permission: 'create_content_views',
        templateUrl: 'content-views/details/views/content-view-copy.html',
        ncyBreadcrumb: {
            label: '{{ "Copy" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.publish', {
        url: '/publish',
        permission: 'publish_content_views',
        controller: 'ContentViewPublishController',
        templateUrl: 'content-views/details/views/content-view-publish.html',
        ncyBreadcrumb: {
            label: '{{ "Publish" | translate }}',
            parent: 'content-view.info'
        }
    })

    .state('content-view.yum', {
        url: '/repositories/yum',
        abstract: true,
        template: '<div ui-view></div>'
    })

    .state('content-view.yum.filters', {
        url: '/filters',
        permission: 'view_content_views',
        controller: 'FiltersController',
        templateUrl: 'content-views/details/filters/views/filters.html',
        ncyBreadcrumb: {
            label: '{{ "Yum Filters" | translate }}',
            parent: 'content-view.info'
        }

    })
    .state('content-view.yum.filters.new', {
        url: '/new',
        permission: 'edit_content_views',
        views: {
            '@content-view': {
                controller: 'NewFilterController',
                templateUrl: 'content-views/details/filters/views/new-filter.html'
            }
        },
        ncyBreadcrumb: {
            label: '{{ "Create Yum Filter" | translate }}',
            parent: 'content-view.yum.filters'
        }
    });

    $stateProvider.state('content-view.yum.filter', {
        abstract: true,
        controller: 'FilterDetailsController',
        templateUrl: 'content-views/details/filters/views/filter-details.html'
    })

    .state('content-view.yum.filter.rpm', {
        abstract: true,
        url: '/filters/:filterId/package',
        permission: 'view_content_views',
        controller: 'PackageFilterController',
        templateUrl: 'content-views/details/filters/views/package-filter.html'
    })
    .state('content-view.yum.filter.rpm.details', {
        url: '/details',
        permission: 'view_content_views',
        controller: 'PackageFilterController',
        templateUrl: 'content-views/details/filters/views/package-filter-details.html',
        ncyBreadcrumb: {
            label: '{{ filter.name }}',
            parent: 'content-view.yum.filters'
        }
    })
    .state('content-view.yum.filter.rpm.edit', {
        url: '/edit',
        controller: 'FilterEditController',
        permission: 'edit_content_views',
        templateUrl: 'content-views/details/filters/views/edit-filter.html',
        ncyBreadcrumb: {
            label: '{{ "Edit" | translate}} {{ filter.name }}',
            parent: 'content-view.yum.filters'
        }
    })
    .state('content-view.yum.filter.rpm.repositories', {
        url: '/repositories',
        permission: 'view_content_views',
        controller: 'FilterRepositoriesController',
        templateUrl: 'content-views/details/filters/views/filter-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Repositories" | translate }}',
            parent: 'content-view.yum.filter.rpm.edit'
        }
    })

    .state('content-view.yum.filter.package_group', {
        abstract: true,
        url: '/filters/:filterId/package-group',
        templateUrl: 'content-views/details/filters/views/package-group-filter.html'
    })
    .state('content-view.yum.filter.package_group.edit', {
        url: '/edit',
        controller: 'FilterEditController',
        permission: 'edit_content_views',
        templateUrl: 'content-views/details/filters/views/edit-filter.html',
        ncyBreadcrumb: {
            label: '{{ "Edit" | translate }} {{ filter.name }}',
            parent: 'content-view.yum.filters'
        }
    })
    .state('content-view.yum.filter.package_group.list', {
        url: '/list',
        permission: 'view_content_views',
        controller: 'PackageGroupFilterListController',
        templateUrl: 'content-views/details/filters/views/package-group-filter-details.html',
        ncyBreadcrumb: {
            label: '{{ "Package Groups" | translate }}',
            parent: 'content-view.yum.filter.package_group.edit'
        }
    })
    .state('content-view.yum.filter.package_group.available', {
        url: '/available',
        permission: 'edit_content_views',
        controller: 'AvailablePackageGroupFilterController',
        templateUrl: 'content-views/details/filters/views/package-group-filter-details.html',
        ncyBreadcrumb: {
            label: '{{ "Add Package Groups" | translate }}',
            parent: 'content-view.yum.filter.package_group.edit'
        }
    })
    .state('content-view.yum.filter.package_group.repositories', {
        url: '/repositories',
        permission: 'view_content_views',
        controller: 'FilterRepositoriesController',
        templateUrl: 'content-views/details/filters/views/filter-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Repositories | translate }}',
            parent: 'content-view.yum.filter.package_group.edit'
        }
    })
    .state('content-view.yum.filter.erratum', {
        abstract: true,
        url: '/filters/:filterId/errata',
        controller: 'ErrataFilterController',
        templateUrl: 'content-views/details/filters/views/errata-filter.html'
    })
    .state('content-view.yum.filter.erratum.edit', {
        url: '/edit',
        controller: 'FilterEditController',
        permission: 'edit_content_views',
        templateUrl: 'content-views/details/filters/views/edit-filter.html',
        ncyBreadcrumb: {
            label: '{{ "Edit" | translate }} {{ filter.name }}',
            parent: 'content-view.yum.filters'
        }
    })
    .state('content-view.yum.filter.erratum.list', {
        url: '/list',
        permission: 'view_content_views',
        controller: 'ErrataFilterListController',
        templateUrl: 'content-views/details/filters/views/errata-filter-details.html',
        ncyBreadcrumb: {
            label: '{{ "Erratum" | translate }}',
            parent: 'content-view.yum.filter.erratum.edit'
        }
    })
    .state('content-view.yum.filter.erratum.available', {
        url: '/available',
        permission: 'edit_content_views',
        controller: 'AvailableErrataFilterController',
        templateUrl: 'content-views/details/filters/views/errata-filter-details.html',
        ncyBreadcrumb: {
            label: '{{ "Add Erratum" | translate }}',
            parent: 'content-view.yum.filter.erratum.edit'
        }
    })
    .state('content-view.yum.filter.erratum.dateType', {
        url: '/date_type',
        permission: 'view_content_views',
        controller: 'DateTypeErrataFilterController',
        templateUrl: 'content-views/details/filters/views/date-type-errata-filter.html',
        ncyBreadcrumb: {
            label: '{{ filter.name }}',
            parent: 'content-view.yum.filters'
        }
    })
    .state('content-view.yum.filter.erratum.repositories', {
        url: '/repositories',
        permission: 'view_content_views',
        controller: 'FilterRepositoriesController',
        templateUrl: 'content-views/details/filters/views/filter-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Repositories" | translate }}',
            parent: 'content-view.yum.filter.erratum.edit'
        }
    })
    .state('content-view.yum.filter.module-stream', {
        abstract: true,
        url: '/filters/:filterId/module-stream',
        templateUrl: 'content-views/details/filters/views/module-stream-filter.html'
    })
    .state('content-view.yum.filter.module-stream.edit', {
        url: '/edit',
        controller: 'FilterEditController',
        permission: 'edit_content_views',
        templateUrl: 'content-views/details/filters/views/edit-filter.html',
        ncyBreadcrumb: {
            label: '{{ "Edit" | translate }} {{ filter.name }}',
            parent: 'content-view.yum.filters'
        }
    })
    .state('content-view.yum.filter.module-stream.list', {
        url: '/list',
        permission: 'view_content_views',
        controller: 'ModuleStreamFilterListController',
        templateUrl: 'content-views/details/filters/views/module-stream-filter-details.html',
        ncyBreadcrumb: {
            label: '{{ "Module Streams" | translate }}',
            parent: 'content-view.yum.filter.module-stream.edit'
        }
    })
    .state('content-view.yum.filter.module-stream.available', {
        url: '/available',
        permission: 'edit_content_views',
        controller: 'AvailableModuleStreamFilterController',
        templateUrl: 'content-views/details/filters/views/module-stream-filter-details.html',
        ncyBreadcrumb: {
            label: '{{ "Add Module Streams" | translate }}',
            parent: 'content-view.yum.filter.module-stream.edit'
        }
    })
    .state('content-view.yum.filter.module-stream.repositories', {
        url: '/repositories',
        permission: 'view_content_views',
        controller: 'FilterRepositoriesController',
        templateUrl: 'content-views/details/filters/views/filter-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Repositories | translate }}',
            parent: 'content-view.yum.filter.module-stream.edit'
        }
    })
    .state('content-view.docker', {
        url: '/repositories/docker',
        abstract: true,
        template: '<div ui-view></div>'
    })

    .state('content-view.docker.filters', {
        url: '/filters',
        permission: 'view_content_views',
        controller: 'FiltersController',
        templateUrl: 'content-views/details/filters/views/filters.html',
        ncyBreadcrumb: {
            label: '{{ "Docker Filters" | translate }}',
            parent: 'content-view.info'
        }

    })
    .state('content-view.docker.filters.new', {
        url: '/new',
        permission: 'edit_content_views',
        views: {
            '@content-view': {
                controller: 'NewFilterController',
                templateUrl: 'content-views/details/filters/views/new-filter.html'
            }
        },
        ncyBreadcrumb: {
            label: '{{ "Create Docker Filter" | translate }}',
            parent: 'content-view.docker.filters'
        }
    });

    $stateProvider.state('content-view.docker.filter', {
        abstract: true,
        controller: 'FilterDetailsController',
        templateUrl: 'content-views/details/filters/views/filter-details.html'
    })

    .state('content-view.docker.filter.tag', {
        abstract: true,
        url: '/filters/:filterId/docker',
        permission: 'view_content_views',
        controller: 'DockerTagFilterController',
        templateUrl: 'content-views/details/filters/views/docker-filter.html'
    })
    .state('content-view.docker.filter.tag.details', {
        url: '/details',
        permission: 'view_content_views',
        controller: 'DockerTagFilterController',
        templateUrl: 'content-views/details/filters/views/docker-tag-filter-details.html',
        ncyBreadcrumb: {
            label: '{{ filter.name }}',
            parent: 'content-view.docker.filters'
        }
    })
    .state('content-view.docker.filter.tag.edit', {
        url: '/edit',
        controller: 'FilterEditController',
        permission: 'edit_content_views',
        templateUrl: 'content-views/details/filters/views/edit-filter.html',
        ncyBreadcrumb: {
            label: '{{ "Edit" | translate}} {{ filter.name }}',
            parent: 'content-view.docker.filters'
        }
    })
    .state('content-view.docker.filter.tag.repositories', {
        url: '/repositories',
        permission: 'view_content_views',
        controller: 'FilterRepositoriesController',
        templateUrl: 'content-views/details/filters/views/filter-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Repositories" | translate }}',
            parent: 'content-view.docker.filter.tag.edit'
        }
    })

    .state('content-view.tasks', {
        abstract: true,
        template: '<div ui-view></div>'
    })
    .state('content-view.tasks.index', {
        url: '/tasks',
        permission: 'view_content_views',
        templateUrl: 'content-views/details/views/content-view-details-tasks.html',
        ncyBreadcrumb: {
            label: '{{ "Tasks" | translate }}',
            parent: 'content-view.info'
        }
    })
    .state('content-view.task', {
        url: '/tasks/:taskId',
        permission: 'view_content_views',
        controller: 'TaskDetailsController',
        templateUrl: 'tasks/views/task-details.html',
        ncyBreadcrumb: {
            label: '{{ task.id }}',
            parent: 'content-view.tasks'
        }
    });
}]);
