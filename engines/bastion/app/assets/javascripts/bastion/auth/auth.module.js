/**
 Copyright 2014 Red Hat, Inc.

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
 * @ngdoc module
 * @name  Bastion.auth
 *
 * @description
 *   Module for auth functionality.
 */
angular.module('Bastion.auth', ['Bastion']);

/**
 * @ngdoc object
 * @name Bastion.auth.config
 *
 * @requires $httpProvider
 * @requires $provide
 *
 * @description
 *   Set up the UnauthorizedInterceptor
 */
angular.module('Bastion.auth').config(['$httpProvider', '$provide',
    function ($httpProvider, $provide) {
        $provide.factory('UnauthorizedInterceptor', ['$injector',
                function ($injector) {
                    return {
                        responseError: function (response) {
                            var message,
                                $q = $injector.get('$q'),
                                $window = $injector.get('$window'),
                                translate = $injector.get('translate');

                            if (response.status === 401) {
                                $window.location.href = '/users/login';
                            } else if (response.status === 403) {
                                // Add unauthorized display message to response
                                message = translate('You are not authorized to perform this action.');
                                response.data.errors = [message];
                                response.data.displayMessage = message;
                                return $q.reject(response);
                            } else {
                                return $q.reject(response);
                            }
                        }
                    };
                }]
        );

        $httpProvider.interceptors.push('UnauthorizedInterceptor');
    }
]);

/**
 * @ngdoc run
 * @name Bastion.auth.run
 *
 * @requires $rootScope
 * @requires $window
 * @requires Authorization
 *
 * @description
 *   Check current user permissions and redirect to the 403 page if appropriate
 */
angular.module('Bastion.auth').run(['$rootScope', '$window', 'Authorization',
    function ($rootScope, $window, Authorization) {
        $rootScope.$on('$stateChangeStart', function (event, toState) {
            var permission = toState.permission;
            if (permission !== false && (permission === undefined || Authorization.denied(permission))) {
                $window.location.href = '/katello/403';
            }
        });

        $rootScope.permitted = Authorization.permitted;
        $rootScope.denied = Authorization.denied;
    }
]);
