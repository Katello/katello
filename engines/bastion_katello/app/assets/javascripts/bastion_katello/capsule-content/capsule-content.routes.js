/**
 * @ngdoc object
 * @name Bastion.capsule-content.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.capsule-content').config(['$stateProvider', '$urlRouterProvider', function ($stateProvider, $urlRouterProvider) {

    // Catch the url to prevent the router to perform redirect.
    $urlRouterProvider.when('/smart_proxies/:proxyId', function ($match, $stateParams) {
        $stateParams.pageName = 'smart_proxies/detail';
        return true;
    });

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
