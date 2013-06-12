/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc filter
 * @name  Katello.i18n.filter:i18n
 *
 * @requires i18nDictionary
 *
 * @description
 *   Looks up a key in the i18n dictionary and returns the translated string.
 *
 * @example
 *   {{ "some_i18n_code" | i18n }}
 *   {{ "some_i18n_code_with_replacements" | i18n: ["why", "hello"] }}
 */
angular.module('Katello.i18n').filter('i18n', ['i18nDictionary', function(i18nDictionary) {
    return function(i18nKey, replacements) {
        var translation;
        var translated = i18nKey;

        if (i18nDictionary.hasOwnProperty(i18nKey)) {
            translation = i18nDictionary[i18nKey];
            translated = translation;
            if (typeof translation === 'function') {
                translated = translation.apply(this, replacements);
            }
        }
        return translated;
    };
}]);
