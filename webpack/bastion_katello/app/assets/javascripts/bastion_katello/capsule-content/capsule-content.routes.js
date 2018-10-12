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
    $urlRouterProvider.when('/smart_proxies/:proxyId', ['$match', '$stateParams', function ($match, $stateParams) {
        $stateParams.pageName = 'smart_proxies/detail';
        return true;
    }]);

    // Add rule to redirect links on the smart proxy detail page.
    // Changing state doesn't work there since there's no <ui-view> element there
    $urlRouterProvider.rule(function ($injector, $location) {
        var $stateParams = $injector.get('$stateParams'),
            $window = $injector.get('$window');

        if ($stateParams.pageName === 'smart_proxies/detail') {
            $window.location.href = $location.path();
        }
    });
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
