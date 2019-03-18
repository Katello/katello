/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewPublishController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentView
 * @requires Notification
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewPublishController',
    ['$scope', 'translate', 'ContentView', 'Notification', function ($scope, translate, ContentView, Notification) {

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

        $scope.version = {};

        $scope.publish = function (contentView) {
            var description = $scope.version.description,
                data = {'id': contentView.id, 'description': description};
            $scope.working = true;
            ContentView.publish(data, success, failure);
        };

        //Refetch the content view so that the contentView is updated for latest components
        $scope.fetchContentView();

    }]
);
