/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewPublishController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentView
 * @requires GlobalNotification
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewPublishController',
    ['$scope', 'translate', 'ContentView', 'GlobalNotification', function ($scope, translate, ContentView, GlobalNotification) {

        function success() {
            $scope.transitionTo('content-view.versions',
                                {contentViewId: $scope.contentView.id});

            //get the latest version number from the server
            $scope.$parent.contentView = ContentView.get({id: $scope.$stateParams.contentViewId});

            $scope.working = false;
        }

        function failure(response) {
            GlobalNotification.setErrorMessage(response.data.displayMessage);
            $scope.working = false;
        }

        $scope.version = {};

        $scope.publish = function (contentView) {
            var description = $scope.version.description,
                forceMetadataRegeneration = $scope.version.forceMetadataRegeneration,
                data = {'id': contentView.id, 'description': description, 'force_yum_metadata_regeneration': forceMetadataRegeneration};
            $scope.working = true;
            ContentView.publish(data, success, failure);
        };

    }]
);
