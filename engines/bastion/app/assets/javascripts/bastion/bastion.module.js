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
 * @name  Bastion
 *
 * @description
 *   Base module that defines the Katello module namespace and includes any thirdparty
 *   modules used by the application.
 */
angular.module('Bastion', [
    'alchemy',
    'alchemy.format',
    'alch-templates',
    'ngSanitize',
    'ui.bootstrap',
    'ui.bootstrap.tpls',
    'angular-blocks',
    'Bastion.activation-keys',
    'Bastion.custom-info',
    'Bastion.i18n',
    'Bastion.menu',
    'Bastion.subscriptions',
    'Bastion.systems',
    'Bastion.environments',
    'Bastion.content-views',
    'Bastion.nodes',
    'Bastion.organizations',
    'Bastion.products',
    'Bastion.providers',
    'Bastion.repositories',
    'Bastion.sync-plans',
    'Bastion.system-groups',
    'Bastion.gpg-keys',
    'Bastion.tasks',
    'Bastion.widgets',
    'templates'

]);

/**
 * @ngdoc constant
 * @name Bastion.constant:RootURL
 *
 * @description
 *   Provides a configurable URL root for all requests.
 */
angular.module('Bastion').constant('RootURL', '/katello');

/**
 * @ngdoc config
 * @name  Bastion.config
 *
 * @requires $httpProvider
 * @requires $urlRouterProvider
 * @requires $provide
 * @requires RootURL
 *
 * @description
 *   Used for establishing application wide configuration such as adding the Rails CSRF token
 *   to every request.
 */
angular.module('Bastion').config(
    ['$httpProvider', '$urlRouterProvider', '$provide', 'RootURL',
    function ($httpProvider, $urlRouterProvider, $provide, RootURL) {
        $httpProvider.defaults.headers.common = {
            Accept: 'application/json, text/plain, version=2; */*',
            'X-XSRF-TOKEN': $('meta[name=csrf-token]').attr('content')
        };
        $urlRouterProvider.otherwise("/");

        $provide.factory('PrefixInterceptor', ['$q', '$templateCache', function ($q, $templateCache) {
            return {
                request: function (config) {
                    if (config.url.indexOf('.html') !== -1) {
                        if ($templateCache.get(config.url) === undefined) {
                            config.url = '/' + config.url;
                        }
                    } else if (config.url.match(/^\/\//)) {
                        config.url = config.url.replace(/^\/\//, '/');
                    } else {
                        config.url = RootURL + config.url;
                    }

                    return config || $q.when(config);
                }
            };
        }]);

        $httpProvider.interceptors.push('PrefixInterceptor');
    }]
);


/**
 * @ngdoc run
 * @name Bastion.run
 *
 * @requires $rootScope
 * @requires $state
 * @requires $stateParams
 * @requires gettextCatalog
 * @requires currentLocale
 * @requires $location
 * @requires PageTitle
 * @requires RootURL
 *
 * @description
 *   Set up some common state related functionality and set the current language.
 */
angular.module('Bastion').run(['$rootScope', '$state', '$stateParams', 'gettextCatalog', 'currentLocale', '$location', 'PageTitle', 'RootURL',
    function ($rootScope, $state, $stateParams, gettextCatalog, currentLocale, $location, PageTitle, RootURL) {
        var fromState, fromParams;

        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;
        $rootScope.transitionTo = $state.transitionTo;
        $rootScope.RootURL = RootURL;

        $rootScope.isState = function (stateName) {
            return $state.is(stateName);
        };

        $rootScope.stateIncludes = $state.includes;

        $rootScope.transitionBack = function () {
            if (fromState) {
                $state.transitionTo(fromState, fromParams);
            }
        };

        // Set the current language
        gettextCatalog.currentLanguage = currentLocale;


        // Set the current language
        gettextCatalog.currentLanguage = currentLocale;

        $rootScope.$on('$stateChangeStart',
            function () {
            //save location.search so we can add it back after transition is done
            this.locationSearch = $location.search();
        });

        $rootScope.$on('$stateChangeSuccess',
            function (event, toState, toParams, fromStateIn, fromParamsIn) {
                //restore all query string parameters back to $location.search
                $location.search(this.locationSearch);

                //Record our from state, so we can transition back there
                if (!fromStateIn.abstract) {
                    fromState = fromStateIn;
                    fromParams = fromParamsIn;
                }

                //Pop the last page title if it's not the outermost title (i.e. parent state)
                if (PageTitle.titles.length > 1) {
                    PageTitle.resetToFirst();
                }
            }
        );
    }
]);
