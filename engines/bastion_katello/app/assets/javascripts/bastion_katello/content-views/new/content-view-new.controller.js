/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:NewContentViewController
 *
 * @requires $scope
 * @requires ContentView
 * @requires FormUtils
 * @requires CurrentOrganization
 *
 * @description
 */
angular.module('Bastion.content-views').controller('NewContentViewController',
    ['$scope', 'ContentView', 'FormUtils', 'CurrentOrganization',
    function ($scope, ContentView, FormUtils, CurrentOrganization) {

        function success(response) {
            var successState = 'content-view.repositories.yum.available';

            if (response.composite) {
                successState = 'content-view.components.composite-content-views.available';
            }

            $scope.transitionTo(successState, {contentViewId: response.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.contentViewForm[field].$setValidity('server', false);
                $scope.contentViewForm[field].$error.messages = errors;
            });
        }

        $scope.contentView = new ContentView({'organization_id': CurrentOrganization});
        $scope.createOption = 'new';
        $scope.table = {};

        $scope.save = function (contentView) {
            contentView.$save(success, error);
        };

        $scope.$watch('contentView.name', function () {
            if ($scope.contentViewForm.name) {
                $scope.contentViewForm.name.$setValidity('server', true);
                FormUtils.labelize($scope.contentView);
            }
        });

    }]
);
