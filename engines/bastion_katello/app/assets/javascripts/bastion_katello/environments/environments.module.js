/**
 * @ngdoc module
 * @name  Bastion.environments
 *
 * @description
 *   Module for environments related functionality.
 */
angular.module('Bastion.environments', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.i18n',
    'Bastion.utils',
    'Bastion.components',
    'Bastion.errata',
    'Bastion.packages',
    'Bastion.ostree-branches',
    'Bastion.puppet-modules',
    'Bastion.repositories',
    'Bastion.content-views',
    'Bastion.dates'
]);
