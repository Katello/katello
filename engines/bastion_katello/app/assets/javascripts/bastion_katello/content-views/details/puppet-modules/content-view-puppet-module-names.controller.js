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
    ['$scope', 'Nutupane', 'ContentView', function ($scope, Nutupane, ContentView) {

        var nutupane = new Nutupane(
            ContentView,
            {id: $scope.$stateParams.contentViewId},
            'availablePuppetModuleNames'
        );

        $scope.detailsTable = nutupane.table;

        $scope.selectVersion = function (moduleName) {
            $scope.transitionTo('content-views.details.puppet-modules.versions',
                {
                    contentViewId: $scope.$stateParams.contentViewId,
                    moduleName: moduleName
                }
            );
        };

    }]
);
