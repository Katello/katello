angular.module('Bastion.activation-keys').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('activation-keys', {
        url: '/activation_keys',
        permission: 'view_activation_keys',
        template: '<div ui-view></div>',
        views: {
            '@': {
                controller: 'ActivationKeysController',
                templateUrl: 'activation-keys/views/activation-keys.html'
            }
        },
        ncyBreadcrumb: {
            label: '{{ "Activation Keys" | translate }}'
        }
    })
    .state('activation-keys.new', {
        url: '/new',
        permission: 'create_activation_keys',
        views: {
            '@': {
                controller: 'NewActivationKeyController',
                templateUrl: 'activation-keys/new/views/activation-key-new.html'
            }
        },
        ncyBreadcrumb: {
            label: '{{ "New Activation Key" | translate }}',
            parent: 'activation-keys'
        }
    });

    $stateProvider.state("activation-key", {
        abstract: true,
        url: '/activation_keys/:activationKeyId',
        permission: 'view_activation_keys',
        controller: 'ActivationKeyDetailsController',
        templateUrl: 'activation-keys/details/views/activation-key-details.html'
    })
    .state('activation-key.info', {
        url: '',
        permission: 'view_activation_keys',
        controller: 'ActivationKeyDetailsInfoController',
        templateUrl: 'activation-keys/details/views/activation-key-info.html',
        ncyBreadcrumb: {
            label: '{{ activationKey.name }}',
            parent: 'activation-keys'
        }
    })
    .state('activation-key.products', {
        url: '/products',
        permission: 'view_activation_keys',
        controller: 'ActivationKeyRepositorySetsController',
        templateUrl: 'activation-keys/details/views/activation-key-repository-sets.html',
        ncyBreadcrumb: {
            label: '{{ "Repository Sets" | translate }}',
            parent: 'activation-key.info'
        }
    })
    .state('activation-key.subscriptions', {
        abstract: true,
        templateUrl: 'activation-keys/details/views/activation-key-subscriptions.html'
    })
    .state('activation-key.subscriptions.list', {
        url: '/subscriptions',
        permission: 'view_activation_keys',
        controller: 'ActivationKeySubscriptionsController',
        templateUrl: 'activation-keys/details/views/activation-key-subscriptions-list.html',
        ncyBreadcrumb: {
            label: '{{ "List Subscriptions" | translate }}',
            parent: 'activation-key.info'
        }
    })
    .state('activation-key.subscriptions.add', {
        url: '/add-subscriptions',
        permission: 'edit_activation_keys',
        controller: 'ActivationKeyAddSubscriptionsController',
        templateUrl: 'activation-keys/details/views/activation-key-add-subscriptions.html',
        ncyBreadcrumb: {
            label: '{{ "Add Subscriptions" | translate }}',
            parent: 'activation-key.info'
        }
    });

    $stateProvider.state('activation-key.host-collections', {
        abstract: true,
        templateUrl: 'activation-keys/details/views/activation-key-host-collections.html'
    })
    .state('activation-key.host-collections.list', {
        url: '/host-collections',
        permission: 'view_activation_keys',
        controller: 'ActivationKeyHostCollectionsController',
        templateUrl: 'activation-keys/details/views/activation-key-host-collections-table.html',
        ncyBreadcrumb: {
            label: '{{ "List Host Collections" | translate }}',
            parent: 'activation-key.info'
        }
    })
    .state('activation-key.host-collections.add', {
        url: '/host-collections/add',
        permission: 'edit_activation_keys',
        controller: 'ActivationKeyAddHostCollectionsController',
        templateUrl: 'activation-keys/details/views/activation-key-host-collections-table.html',
        ncyBreadcrumb: {
            label: '{{ "Add Host Collections" | translate }}',
            parent: 'activation-key.info'
        }
    })
    .state('activation-key.associations-content-hosts', {
        url: '/associations/content-hosts',
        permission: 'view_activation_keys',
        controller: 'ActivationKeyAssociationsController',
        templateUrl: 'activation-keys/details/views/activation-key-associations-content-hosts.html',
        ncyBreadcrumb: {
            label: '{{ "Content Hosts" | translate }}',
            parent: 'activation-key.info'
        }
    })
    .state('activation-key.copy', {
        url: '/copy',
        permission: 'create_activation_key',
        controller: 'ActivationKeyCopyController',
        templateUrl: 'activation-keys/details/views/activation-key-copy.html',
        ncyBreadcrumb: {
            label: "{{ 'Create Copy' | translate }}",
            parent: 'activation-key.info'
        }
    });
}]);
