/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:NewContentViewController
 *
 * @requires $scope
 * @requires ContentView
 * @requires FormUtils
 * @requires CurrentOrganization
 * @requires contentViewSolveDependencies
 *
 * @description
 */
angular.module('Bastion.content-views').controller('NewContentViewController',
    ['$scope', 'ContentView', 'FormUtils', 'CurrentOrganization', 'contentViewSolveDependencies',
    function ($scope, ContentView, FormUtils, CurrentOrganization, contentViewSolveDependencies) {

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
        /* eslint-disable camelcase */
        // boolean is passed in as a string since it comes from rails app by way of bastion.
        $scope.contentView.solve_dependencies = contentViewSolveDependencies === 'true';
        /* eslint-enable camelcase */
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

        $scope.$watch('contentView.composite', function () {
            if ($scope.contentView.composite) {
                /* eslint-disable camelcase */
                $scope.contentView.solve_dependencies = false;
            } else {
                $scope.contentView.auto_publish = false;
                /* eslint-enable camelcase */
            }
        });
    }]
);
