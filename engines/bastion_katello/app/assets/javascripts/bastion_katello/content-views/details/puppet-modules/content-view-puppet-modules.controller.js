/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewPuppetModulesController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires ContentViewPuppetModule
 *
 * @description
 *   Provides functionality to the Content View existing Puppet Modules list.
 */
angular.module('Bastion.content-views').controller('ContentViewPuppetModulesController',
    ['$scope', 'translate', 'Nutupane', 'ContentViewPuppetModule',
    function ($scope, translate, Nutupane, ContentViewPuppetModule) {
        var nutupane = new Nutupane(ContentViewPuppetModule, {
            contentViewId: $scope.$stateParams.contentViewId
        });

        nutupane.masterOnly = true;

        $scope.detailsTable = nutupane.table;
        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.versionText = function (module) {
            var version = translate("Latest (Currently %s)").replace('%s', module['computed_version']);
            if (module['puppet_module']) {
                version = module['puppet_module'].version;
            }
            return version;
        };

        $scope.selectNewVersion = function (module) {
            $scope.transitionTo('content-views.details.puppet-modules.versionsForModule',
                {
                    contentViewId: $scope.$stateParams.contentViewId,
                    moduleName: module.name,
                    moduleId: module.id
                }
            );
        };

        $scope.removeModule = function (module) {
            var success, error;

            success = function () {
                $scope.successMessages = [translate('Module %s removed from Content View.')
                    .replace('%s', module.name)];
                nutupane.removeRow(module.id);
            };

            error = function (response) {
                angular.forEach(response.data.errors, function (errorMessage) {
                    $scope.errorMessages = [translate("An error occurred updating the Content View: ") + errorMessage];
                });
            };

            ContentViewPuppetModule.remove({
                contentViewId: $scope.$stateParams.contentViewId,
                id: module.id
            }, success, error);
        };

    }]
);
