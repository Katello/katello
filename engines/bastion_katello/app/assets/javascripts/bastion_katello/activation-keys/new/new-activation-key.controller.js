/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:NewActivationKeyController
 *
 * @requires $scope
 * @requires $q
 * @requires FormUtils
 * @requires ActivationKey
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 *
 * @description
 *   Controls the creation of an empty ActivationKey object for use by sub-controllers.
 */
angular.module('Bastion.activation-keys').controller('NewActivationKeyController',
    ['$scope', '$q', 'FormUtils', 'ActivationKey', 'Organization', 'CurrentOrganization', 'ContentView',
    function ($scope, $q, FormUtils, ActivationKey, Organization, CurrentOrganization, ContentView) {

        function success() {
            $scope.transitionTo('activation-key.info', {activationKeyId: $scope.activationKey.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.activationKeyForm[field].$setValidity('server', false);
                $scope.activationKeyForm[field].$error.messages = errors;
            });
        }

        $scope.activationKey = $scope.activationKey || new ActivationKey();
        $scope.activationKey['unlimited_hosts'] = true;

        $scope.panel = {loading: false};
        $scope.organization = CurrentOrganization;

        $scope.contentViews = [];
        $scope.editContentView = false;
        $scope.environments = [];

        $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

        $scope.$watch('activationKey.environment', function (environment) {
            if (environment) {
                $scope.editContentView = true;
                ContentView.queryUnpaged({ 'environment_id': environment.id }, function (response) {
                    $scope.contentViews = response.results;
                });
            }
        });

        $scope.save = function (activationKey) {
            activationKey['organization_id'] = CurrentOrganization;
            activationKey.$save(success, error);
        };

    }]
);
