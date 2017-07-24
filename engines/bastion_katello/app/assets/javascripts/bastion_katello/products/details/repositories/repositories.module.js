/**
 * @ngdoc module
 * @name  Bastion.repositories
 *
 * @description
 *   Module for repository related functionality.
 */
angular.module('Bastion.repositories', [
    'ngResource',
    'ui.router',
    'ngUpload',
    'Bastion',
    'Bastion.i18n',
    'Bastion.utils',
    'Bastion.common',
    'Bastion.components',
    'Bastion.components.formatters',
    'Bastion.packages',
    'Bastion.products',
    'Bastion.docker-manifests',
    'Bastion.docker-manifest-lists',
    'Bastion.files',
    'Bastion.debs'
]);

angular.module('Bastion.repositories').run(['$rootScope', '$state', '$stateParams',
    function ($rootScope, $state, $stateParams) {
        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;
    }
]);
