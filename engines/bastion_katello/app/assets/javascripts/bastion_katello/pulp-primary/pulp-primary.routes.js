/**
* @ngdoc object
* @name Bastion.pulp-primary.config
*
* @requires $stateProvider
* @requires $urlRouterProvider
*
* @description
*   Used for systems level configuration such as setting up the ui state machine.
*/
angular.module('Bastion.pulp-primary').config(['$stateProvider', '$urlRouterProvider', function ($stateProvider, $urlRouterProvider) {
    //Catch the url to prevent the router to perform redirect.
    $urlRouterProvider.when('/smart_proxies/:proxyId', [function () {
        return true;
    }]);
}]);
