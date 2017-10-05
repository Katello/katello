/**
 * @ngdoc module
 * @name  Bastion.content-hosts
 *
 * @description
 *   Module for content hosts related functionality.
 */
angular.module('Bastion.content-hosts', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.i18n',
    'Bastion.common',
    'Bastion.components',
    'Bastion.components.formatters',
    'Bastion.organizations',
    'Bastion.subscriptions',
    'Bastion.capsules',
    'Bastion.hosts',
    'Bastion.errata',
    'Bastion.host-collections',
    'Bastion.repository-sets',
    'Bastion.dates'
]);
