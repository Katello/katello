/**
 * @ngdoc module
 * @name  Bastion.auth
 *
 * @description
 *   Module for auth functionality.
 */
angular.module('Bastion.auth', []);

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
                                // Reload current page if API request in order to
                                // ensure correct redirect upon login.
                                if (response.config.url.indexOf('api') >= 0) {
                                    $window.location.reload();
                                } else {
                                    $window.location.href = '/users/login';
                                }
                            } else if (response.status === 403) {
                                // Add unauthorized display message to response
                                message = translate('You are not authorized to perform this action.');
                                response.data.errors = [message];
                                response.data.displayMessage = message;
                            }

                            return $q.reject(response);
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
 * @requires $location
 * @requires Authorization
 *
 * @description
 *   Check current user permissions and redirect to the 403 page if appropriate
 */
angular.module('Bastion.auth').run(['$rootScope', '$location', 'Authorization',
    function ($rootScope, $location, Authorization) {

        function isAuthorized(permission) {
            return !(permission !== false && (angular.isUndefined(permission) || Authorization.denied(permission)));
        }

        $rootScope.$on('$stateChangeStart', function (event, toState) {
            var permission = toState.permission, permitted;

            if (!(permission instanceof Array)) {
                permission = [permission];
            }

            permitted = _.find(permission, function (perm) {
                return isAuthorized(perm);
            });

            if (angular.isUndefined(permitted)) {
                $location.path('/katello/403');
            }
        });

        $rootScope.permitted = Authorization.permitted;
        $rootScope.denied = Authorization.denied;
    }
]);
