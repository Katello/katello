/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewPublishController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentView
 * @requires Notification
 * @requires contentViewSolveDependencies
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewPublishController',
    ['$scope', 'translate', 'ContentView', 'Notification', 'contentViewSolveDependencies',
    function ($scope, translate, ContentView, Notification, contentViewSolveDependencies) {

        // boolean is passed in as a string since it comes from rails app by way of bastion.
        var solveDependenciesSetting = contentViewSolveDependencies === 'true';

        function success() {
            $scope.transitionTo('content-view.versions',
                                {contentViewId: $scope.contentView.id});

            //get the latest version number from the server
            $scope.$parent.contentView = ContentView.get({id: $scope.$stateParams.contentViewId});

            $scope.working = false;
        }

        function failure(response) {
            Notification.setErrorMessage(response.data.displayMessage);
            $scope.working = false;
        }

        $scope.calculateSolveDeps = function(contentViewSolveDep, solveDepSetting, skipSolveDep) {
            var solveDependencies = contentViewSolveDep;
            if (solveDepSetting) {
                solveDependencies = true;
            }
            if (skipSolveDep) {
                solveDependencies = false;
            }
            return solveDependencies;
        };

        $scope.version = {};

        $scope.showSolveDepsSkip = function(contentView) {
            return contentView.solve_dependencies || solveDependenciesSetting;
        };

        $scope.publish = function (contentView) {
            var contentViewSolveDep = contentView.solve_dependencies,
                skipSolveDep = $scope.version.skipSolveDependencies,
                solveDependenciesParam = $scope.calculateSolveDeps(contentViewSolveDep, solveDependenciesSetting, skipSolveDep),
                description = $scope.version.description,
                data = {
                  'id': contentView.id,
                  'description': description,
                  'solve_dependencies': solveDependenciesParam
                };

            $scope.working = true;
            ContentView.publish(data, success, failure);
        };

        //Refetch the content view so that the contentView is updated for latest components
        $scope.fetchContentView();
    }]
);
