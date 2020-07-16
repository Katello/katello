/**
* @ngdoc object
* @name Bastion.capsule-content.config
*
* @requires $stateProvider
* @requires $urlRouterProvider
*
* @description
*   Used for systems level configuration such as setting up the ui state machine.
*/
angular.module('Bastion.capsule-content').config(['$stateProvider', '$urlRouterProvider', function ($stateProvider, $urlRouterProvider) {
    //Catch the url to prevent the router to perform redirect.
    $urlRouterProvider.when('/smart_proxies/:proxyId', [function () {
        return true;
    }]);
}]);

/**
 * @ngdoc run
 * @name Bastion.capsule-content.run
 *
 * @requires $rootScope
 * @requires $window
 * @requires $timeout
 *
 * @description
 *   Ensure foreman's setTab() function is called on capsule content pages.
 */
angular.module('Bastion.capsule-content').run(['$rootScope', '$window', '$timeout', function ($rootScope, $window, $timeout) {
    var smartProxiesRegex = new RegExp("/smart_proxies/.+#.+");
    $rootScope.$on('$locationChangeStart', function (event, newUrl) {
        if (newUrl.match(smartProxiesRegex)) {
            $timeout(function () {
                $window.setTab();
            });
        }
    });
}]);
