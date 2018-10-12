/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewPuppetModulesController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires ContentView
 *
 * @description
 *   Provides functionality to the puppet modules name list.
 */
angular.module('Bastion.content-views').controller('ContentViewPuppetModuleNamesController',
    ['$scope', 'Nutupane', 'ContentView', 'CurrentOrganization', 'PuppetModule',
    function ($scope, Nutupane, ContentView, CurrentOrganization, PuppetModule) {

        var nutupane = new Nutupane(
            ContentView,
            {id: $scope.$stateParams.contentViewId},
            'availablePuppetModuleNames'
        );
        $scope.controllerName = 'katello_content_views';
        nutupane.masterOnly = true;
        $scope.table = nutupane.table;

        $scope.table.fetchAutocomplete = function (term) {
            var promise;

            promise = PuppetModule.autocomplete({'organization_id': CurrentOrganization, search: term}).$promise;

            return promise.then(function (data) {
                return data;
            });
        };

        $scope.selectVersion = function (moduleName) {
            $scope.transitionTo('content-view.puppet-modules.versions',
                {
                    contentViewId: $scope.$stateParams.contentViewId,
                    moduleName: moduleName
                }
            );
        };

    }]
);
