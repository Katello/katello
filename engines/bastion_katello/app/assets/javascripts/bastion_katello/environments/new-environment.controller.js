(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.environments.controller:NewEnvironmentController
     *
     * @description
     *   Handles creating a new environment.
     */
    function NewEnvironmentController($scope, Environment, FormUtils, Notification, PathsService) {

        function success() {
            $scope.transitionTo('environments');
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                if ($scope.environmentForm.hasOwnProperty(field)) {
                    $scope.environmentForm[field].$setValidity('server', false);
                    $scope.environmentForm[field].$error.messages = errors;
                } else {
                    Notification.setErrorMessage(errors);
                }
            });
        }

        $scope.loading = true;
        $scope.environment = new Environment();
        $scope.priorEnvironment = Environment.get({id: $scope.$stateParams.priorId});

        $scope.priorEnvironment.$promise.then(function (prior) {
            PathsService.getCurrentPath(prior).then(function (path) {
                $scope.currentPath = path || null;
                $scope.environment['prior_id'] = $scope.priorEnvironment.id;
                if (path) {
                    $scope.environment['path_id'] = $scope.currentPath[1].id;
                }
                $scope.loading = false;
            });
        });

        $scope.save = function (environment) {
            environment.$save(success, error);
        };

        $scope.$watch('environment.name', function () {
            if ($scope.environmentForm.name) {
                $scope.environmentForm.name.$setValidity('server', true);
                FormUtils.labelize($scope.environment);
            }
        });

        $scope.$watch('environment.prior_id', function (priorId) {
            angular.forEach($scope.currentPath, function (env) {
                if (env.id === priorId) {
                    $scope.priorEnvironment = env;
                }
            });
        });
    }

    angular
        .module('Bastion.environments')
        .controller('NewEnvironmentController', NewEnvironmentController);

    NewEnvironmentController.$inject = ['$scope', 'Environment', 'FormUtils', 'Notification', 'PathsService'];

})();
