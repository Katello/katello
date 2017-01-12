(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.environments.controller:NewEnvironmentController
     *
     * @description
     *   Handles creating a new environment.
     */
    function NewEnvironmentController($scope, Environment, FormUtils) {

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
                    $scope.errorMessages.push(errors);
                }
            });
        }

        $scope.errorMessages = [];
        $scope.successMessages = [];

        $scope.loading = true;
        $scope.environment = new Environment();
        $scope.priorEnvironment = Environment.get({id: $scope.$stateParams.priorId});

        $scope.priorEnvironment.$promise.then(function () {
            $scope.loading = false;
        });

        $scope.save = function (environment) {
            environment['prior_id'] = $scope.$stateParams.priorId;
            environment.$save(success, error);
        };

        $scope.$watch('environment.name', function () {
            if ($scope.environmentForm.name) {
                $scope.environmentForm.name.$setValidity('server', true);
                FormUtils.labelize($scope.environment);
            }
        });

    }

    angular
        .module('Bastion.environments')
        .controller('NewEnvironmentController', NewEnvironmentController);

    NewEnvironmentController.$inject = ['$scope', 'Environment', 'FormUtils'];

})();
