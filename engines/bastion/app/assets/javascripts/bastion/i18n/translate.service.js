/**
 * @ngdoc service
 * @name  Bastion.i18n.factory:translate
 *
 * @requires gettextCatalog
 *
 * @description
 *   Provides a wrapper for gettextCatalog.getString().
 */
angular.module('Bastion.i18n').service('translate', ['gettextCatalog', function (gettextCatalog) {
    return function (str) {
        return gettextCatalog.getString(str);
    };
}]);
