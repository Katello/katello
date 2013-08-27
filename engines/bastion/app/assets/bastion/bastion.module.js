/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/**
 * @ngdoc module
 * @name  Katello
 *
 * @description
 *   Base module that defines the Katello module namespace and includes any thirdparty
 *   modules used by the application.
 */
var Katello = angular.module('Katello', [
    'alchemy',
    'alchemy.format',
    'alch-templates',
    'ngSanitize',
    'Katello.globals',
    'Bastion.i18n',
    'Bastion.menu',
    'Bastion.systems',
    'Bastion.environments',
    'Bastion.content-views'
]);

/**
 * @ngdoc config
 * @name  Katello.config
 *
 * @requires $httpProvider
 *
 * @description
 *   Used for establishing application wide configuration such as adding the Rails CSRF token
 *   to every request.
 */
Katello.config(['$httpProvider', function($httpProvider) {
    $httpProvider.defaults.headers.common['X-CSRF-TOKEN'] = $('meta[name=csrf-token]').attr('content');
    $httpProvider.defaults.headers.common['ACCEPT'] = 'version=2,application/json';
}]);


/**
 * @ngdoc run
 * @name Bastion.i18n.dictionary.run
 *
 * @description
 *   Prime the i18n dictionary to avoid delay in translation replacement.
 */
angular.module('Katello').run(['i18nDictionary', function(i18nDictionary) {
    i18nDictionary.get();
}]);
