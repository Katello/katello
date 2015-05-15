(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.environments.controller:EnvironmentController
     *
     * @description
     *   Enter a description!
     */
    function EnvironmentController($scope, Environment, translate, ContentService) {

        $scope.contentTypes = ContentService.contentTypes;
        $scope.errorMessages = [];
        $scope.successMessages = [];
        $scope.environment = new Environment({id: $scope.$stateParams.environmentId});

        $scope.environment.$get();

        $scope.save = function (environment) {
            var promise;

            function success() {
                $scope.successMessages.push(translate('Environment saved'));
            }

            function error(response) {
                angular.forEach(response.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(translate("An error occurred saving the Environment: ") + errorMessage);
                });
            }

            promise = environment.$update();
            promise.then(success, error);

            return promise;
        };

        $scope.remove = function (environment) {
            var promise;

            function success() {
                $scope.successMessages.push(translate('Remove Successful.'));
                $scope.transitionTo('environments.index');
            }

            function error(response) {
                $scope.errorMessages.push(translate("An error occurred removing the environment: ") +
                    response.data.displayMessage);
            }

            promise = environment.$delete();
            promise.then(success, error);

            return promise;
        };

    }

    angular
        .module('Bastion.environments')
        .controller('EnvironmentController', EnvironmentController);

    EnvironmentController.$inject = ['$scope', 'Environment', 'translate', 'ContentService'];

})();
