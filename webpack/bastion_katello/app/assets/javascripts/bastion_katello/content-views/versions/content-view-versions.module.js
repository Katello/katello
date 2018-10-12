/**
 * @ngdoc module
 * @name  Bastion.content-views.versions
 *
 * @description
 *   Module for content view version related functionality.
 */
angular.module('Bastion.content-views.versions', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.i18n',
    'Bastion.components',
    'Bastion.repositories',
    'Bastion.packages',
    'Bastion.errata',
    'Bastion.package-groups',
    'Bastion.puppet-modules',
    'Bastion.ostree-branches',
    'Bastion.module-streams',
    'Bastion.files',
    'Bastion.debs'
]);
