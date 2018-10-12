/**
 * @ngdoc module
 * @name  Bastion.products
 *
 * @description
 *   Module for product related functionality.
 */
angular.module('Bastion.products', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.components',
    'Bastion.content-credentials',
    'Bastion.architectures',
    'Bastion.i18n',
    'Bastion.sync-plans',
    'Bastion.tasks',
    'Bastion.utils'
]);
