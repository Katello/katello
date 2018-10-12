/**
 * @ngdoc object
 * @name Bastion.content-credentials.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.content-credentials').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('content-credentials', {
        url: '/content_credentials',
        permission: 'view_content_credentials',
        template: '<div ui-view></div>',
        views: {
            '@': {
                controller: 'ContentCredentialsController',
                templateUrl: 'content-credentials/views/content-credentials.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{ 'Content Credential' | translate}}"
        }
    })
    .state('content-credentials.new', {
        url: '/new',
        permission: 'create_content_credentials',
        views: {
            '@': {
                controller: 'NewContentCredentialController',
                templateUrl: 'content-credentials/new/views/new-content-credential.html'
            }
        },
        ncyBreadcrumb: {
            label: "{{'New Content Credential' | translate }}",
            parent: 'content-credentials'
        }
    })
    .state("content-credential", {
        abstract: true,
        url: '/content_credentials/:contentCredentialId',
        permission: 'view_content_credentials',
        controller: 'ContentCredentialDetailsController',
        templateUrl: 'content-credentials/details/views/content-credential-details.html'
    })
    .state('content-credential.info', {
        url: '',
        permission: 'view_content_credentials',
        controller: 'ContentCredentialDetailsInfoController',
        templateUrl: 'content-credentials/details/views/content-credential-info.html',
        ncyBreadcrumb: {
            label: "{{ contentCredential.name }}",
            parent: 'content-credentials'
        }
    })
    .state('content-credential.products', {
        url: '/products',
        permission: 'view_content_credentials',
        controller: 'ContentCredentialProductsController',
        templateUrl: 'content-credentials/details/views/content-credential-products.html',
        ncyBreadcrumb: {
            label: "{{ 'Products' | translate }}",
            parent: 'content-credential.info'
        }
    })
    .state('content-credential.repositories', {
        url: '/repositories',
        permission: 'view_content_credentials',
        controller: 'ContentCredentialRepositoriesController',
        templateUrl: 'content-credentials/details/views/content-credential-repositories.html',
        ncyBreadcrumb: {
            label: "{{ 'Repositories' | translate }}",
            parent: 'content-credential.info'
        }
    });
}]);
