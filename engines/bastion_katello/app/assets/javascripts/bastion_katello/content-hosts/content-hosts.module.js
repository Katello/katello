/**
 * @ngdoc module
 * @name  Bastion.content-hosts
 *
 * @description
 *   Module for content hosts bulk actions functionality.
 *   Note: Legacy Content Hosts UI has been removed. This module now only
 *   contains bulk action modals used by Host Collections.
 */
angular.module('Bastion.content-hosts', [
    'ngResource',
    'Bastion',
    'Bastion.i18n',
    'Bastion.common',
    'Bastion.hosts',
    'Bastion.errata',
    'Bastion.host-collections'
]);
