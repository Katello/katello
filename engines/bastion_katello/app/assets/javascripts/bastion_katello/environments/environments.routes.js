/**
 * @ngdoc object
 * @name Bastion.environments.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.environments').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('environments', {
        url: '/lifecycle_environments',
        permission: 'view_lifecycle_environments',
        template: '<div ui-view></div>',
        views: {
            '@': {
                controller: 'EnvironmentsController',
                templateUrl: 'environments/views/environments.html'
            }
        },
        ncyBreadcrumb: {
            label: '{{ "Environments" | translate }}'
        }
    });

    $stateProvider.state('environments.new', {
        url: '/lifecycle_environments/:priorId/new',
        permission: 'create_lifecycle_environments',
        views: {
            '@': {
                controller: 'NewEnvironmentController',
                templateUrl: 'environments/views/new-environment.html'
            }
        },
        ncyBreadcrumb: {
            label: '{{ "New Environment" | translate }}',
            parent: 'environments'
        }
    });

    $stateProvider.state('environment', {
        abstract: true,
        url: '/lifecycle_environments/:environmentId',
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentController',
        templateUrl: 'environments/details/views/environment.html'
    })
    .state('environment.details', {
        url: '',
        permission: 'view_lifecycle_environments',
        templateUrl: 'environments/details/views/environment-details.html',
        ncyBreadcrumb: {
            label: '{{ environment.name }}',
            parent: 'environments'
        }
    })
    .state('environment.errata', {
        url: '/errata?repositoryId&contentViewId',
        reloadOnSearch: false,
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentContentController',
        templateUrl: 'environments/details/views/environment-errata.html',
        ncyBreadcrumb: {
            label: '{{ "Errata" | translate }}',
            parent: 'environment.details'
        }
    })
    .state('environment.repositories', {
        url: '/repositories?contentViewId',
        reloadOnSearch: false,
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentContentController',
        templateUrl: 'environments/details/views/environment-repositories.html',
        ncyBreadcrumb: {
            label: '{{ "Repositories" | translate }}',
            parent: 'environment.details'
        }
    })
    .state('environment.packages', {
        url: '/packages?repositoryId&contentViewId',
        reloadOnSearch: false,
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentContentController',
        templateUrl: 'environments/details/views/environment-packages.html',
        ncyBreadcrumb: {
            label: '{{ "Packages" | translate }}',
            parent: 'environment.details'
        }
    })
    .state('environment.module-streams', {
        url: '/module-streams?repositoryId&contentViewId',
        reloadOnSearch: false,
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentContentController',
        templateUrl: 'environments/details/views/environment-module-streams.html',
        ncyBreadcrumb: {
            label: '{{ "Module Streams" | translate }}',
            parent: 'environment.details'
        }
    })
    .state('environment.puppet-modules', {
        url: '/puppet-modules?contentViewId',
        reloadOnSearch: false,
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentContentController',
        templateUrl: 'environments/details/views/environment-puppet-modules.html',
        ncyBreadcrumb: {
            label: '{{ "Puppet Modules" | translate }}',
            parent: 'environment.details'
        }
    })
    .state('environment.docker', {
        url: '/docker?repositoryId&contentViewId',
        reloadOnSearch: false,
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentContentController',
        templateUrl: 'environments/details/views/environment-docker.html',
        ncyBreadcrumb: {
            label: '{{ "Docker" | translate }}',
            parent: 'environment.details'
        }
    })
    .state('environment.ostree', {
        url: '/ostree?repositoryId&contentViewId',
        reloadOnSearch: false,
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentContentController',
        templateUrl: 'environments/details/views/environment-ostree.html',
        ncyBreadcrumb: {
            label: '{{ "OSTree Branches" | translate }}',
            parent: 'environment.details'
        }
    })
    .state('environment.content-views', {
        url: '/content-views',
        reloadOnSearch: false,
        permission: 'view_lifecycle_environments',
        controller: 'EnvironmentContentController',
        templateUrl: 'environments/details/views/environment-content-views.html',
        ncyBreadcrumb: {
            label: '{{ "Content Views" | translate }}',
            parent: 'environment.details'
        }
    });

}]);
