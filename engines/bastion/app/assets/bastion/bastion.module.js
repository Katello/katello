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
    'angular-blocks',
    'Katello.globals',
    'Bastion.i18n',
    'Bastion.menu',
    'Bastion.systems',
    'Bastion.environments',
    'Bastion.content-views',
    'Bastion.nodes',
    'Bastion.organizations',
    'Bastion.products',
    'Bastion.providers',
    'Bastion.repositories',
    'Bastion.system-groups',
    'Bastion.gpg-keys',
    'Bastion.tasks'
]);

/**
 * @ngdoc config
 * @name  Bastion.config
 *
 * @requires $httpProvider
 * @requires $urlRouterProvider
 *
 * @description
 *   Used for establishing application wide configuration such as adding the Rails CSRF token
 *   to every request.
 */
angular.module('Bastion').config(['$httpProvider', '$urlRouterProvider', function($httpProvider, $urlRouterProvider) {
    $httpProvider.defaults.headers.common = {
        Accept: 'application/json, text/plain, version=2; */*',
        'X-XSRF-TOKEN': $('meta[name=csrf-token]').attr('content')
    };
    $urlRouterProvider.otherwise("/");
}]);


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
 *
 * @description
 *   Set up some common state related functionality and set the current language.
 */
angular.module('Bastion').run(['$rootScope', '$state', '$stateParams', '$templateCache', 'gettextCatalog', 'currentLocale', '$location',
    function($rootScope, $state, $stateParams, $templateCache, gettextCatalog, currentLocale, $location) {

        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;
        $rootScope.transitionTo = $state.transitionTo;

        $rootScope.isState = function (stateName) {
            return $state.is(stateName);
        };

        $rootScope.stateIncludes = $state.includes;

        // Set the current language
        gettextCatalog.currentLanguage = currentLocale;


        // Set the current language
        gettextCatalog.currentLanguage = currentLocale;

        // Temporary workaround until angular-ui-bootstrap releases bootstrap 3 support.
        $templateCache.put('template/modal/backdrop.html', '<div class="modal-backdrop fade" ng-class="{in: animate}" ng-style="{\'z-index\': 1040 + index*10}"></div>');
        $templateCache.put('template/modal/window.html', '<div class="modal fade {{ windowClass }}" ng-class="{in: animate}" ng-style="{\'z-index\': 1050 + index*10, display: \'block\'}" ng-click="close($event)"><div class="modal-dialog"><div class="modal-content" ng-transclude></div></div></div>');
        $templateCache.put('template/tooltip/tooltip-popup.html', '<div class="tooltip {{placement}}" ng-class="{ in: isOpen(), fade: animation() }"><div class="tooltip-arrow"></div><div class="tooltip-inner" ng-bind="content"></div></div>');

        $rootScope.$on('$stateChangeStart',
            function() {
            //save location.search so we can add it back after transition is done
            this.locationSearch = $location.search();
        });

        $rootScope.$on('$stateChangeSuccess',
            function() {
                //restore all query string parameters back to $location.search
                $location.search(this.locationSearch);
        });

    }
]);
