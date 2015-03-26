/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

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

        function success() {
            $scope.transitionTo('environments.index');
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.environmentForm[field].$setValidity('server', false);
                $scope.environmentForm[field].$error.messages = errors;
            });
        }

    }

    angular
        .module('Bastion.environments')
        .controller('NewEnvironmentController', NewEnvironmentController);

    NewEnvironmentController.$inject = ['$scope', 'Environment', 'FormUtils'];

})();
