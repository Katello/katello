/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewPuppetModulesController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentView
 * @requires ContentViewPuppetModule
 *
 * @description
 *   Provides the ability to select a version of a Puppet Module for a Content View.
 */
angular.module('Bastion.content-views').controller('ContentViewPuppetModuleVersionsController',
    ['$scope', 'translate', 'ContentView', 'ContentViewPuppetModule',
    function ($scope, translate, ContentView, ContentViewPuppetModule) {
        var success, error;

        $scope.versionsLoading = true;
        $scope.successMessages = [];
        $scope.erroressages = [];

        $scope.versions = ContentView.availablePuppetModules(
            {
                name: $scope.$stateParams.moduleName,
                id: $scope.$stateParams.contentViewId
            }, function () {
                $scope.versionsLoading = false;
            }
        );

        $scope.selectVersion = function (module) {
            var contentViewPuppetModule, contentViewPuppetModuleData = {
                contentViewId: $scope.$stateParams.contentViewId,
                uuid: module.uuid,
                author: module.author,
                name: module.name
            };

            if (module.useLatest) {
                contentViewPuppetModuleData.uuid = null;
            }

            contentViewPuppetModule = new ContentViewPuppetModule(contentViewPuppetModuleData);

            if ($scope.$stateParams.moduleId) {
                contentViewPuppetModule.uuid = $scope.$stateParams.moduleId;
                contentViewPuppetModule.$update(success, error);
            } else {
                contentViewPuppetModule.$save(success, error);
            }
        };

        success = function () {
            $scope.transitionTo('content-views.details.puppet-modules.list',
                {contentViewId: $scope.$stateParams.contentViewId});
            $scope.successMessages = [translate('Puppet module added to Content View')];
        };

        error = function (response) {
            angular.forEach(response.data.errors, function (errorMessage) {
                $scope.errorMessages.push(translate("An error occurred updating the Content View: ") + errorMessage);
            });
        };
    }]
);
