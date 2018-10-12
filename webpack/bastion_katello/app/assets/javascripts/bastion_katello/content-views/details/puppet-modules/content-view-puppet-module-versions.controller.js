/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewPuppetModulesController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires ContentView
 * @requires ContentViewPuppetModule
 * @requires Notification
 *
 * @description
 *   Provides the ability to select a version of a Puppet Module for a Content View.
 */
angular.module('Bastion.content-views').controller('ContentViewPuppetModuleVersionsController',
    ['$scope', 'translate', 'Nutupane', 'ContentView', 'ContentViewPuppetModule', 'Notification',
    function ($scope, translate, Nutupane, ContentView, ContentViewPuppetModule, Notification) {
        var success, error, nutupane, params;

        params = {
            name: $scope.$stateParams.moduleName,
            id: $scope.$stateParams.contentViewId,
            'full_result': true
        };

        nutupane = new Nutupane(ContentView, params, 'availablePuppetModules');
        $scope.controllerName = 'katello_content_views';
        nutupane.masterOnly = true;
        $scope.table = nutupane.table;

        $scope.selectVersion = function (module) {
            var contentViewPuppetModule, contentViewPuppetModuleData = {
                contentViewId: $scope.$stateParams.contentViewId,
                uuid: module.uuid,
                author: module.author,
                name: module.name
            };

            contentViewPuppetModule = new ContentViewPuppetModule(contentViewPuppetModuleData);

            if ($scope.$stateParams.moduleId) {
                contentViewPuppetModule.id = $scope.$stateParams.moduleId;
                contentViewPuppetModule.$update(success, error);
            } else {
                contentViewPuppetModule.$save(success, error);
            }
        };

        success = function () {
            $scope.transitionTo('content-view.puppet-modules.list',
                {contentViewId: $scope.$stateParams.contentViewId});
            Notification.setSuccessMessage(translate('Puppet module added to Content View'));
        };

        error = function (response) {
            angular.forEach(response.data.errors, function (errorMessage) {
                Notification.setErrorMessage(translate("An error occurred updating the Content View: ") + errorMessage);
            });
        };
    }]
);
