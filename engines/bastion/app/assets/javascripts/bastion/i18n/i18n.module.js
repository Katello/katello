/**
 * @ngdoc module
 * @name  Bastion.i18n
 *
 * @description
 *   Module for internationalization.
 */
var loadAngularJSi18n = new Event('loadAngularJSi18n');

angular.module('Bastion.i18n', [
    'gettext'
]);

document.dispatchEvent(loadAngularJSi18n);
