/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires ActivationKey
 * @requires ContentView
 * @requires Organization
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the activation key info details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyDetailsInfoController',
    ['$scope', '$q', 'translate', 'ActivationKey', 'ContentView', 'Organization', 'CurrentOrganization',
    function ($scope, $q, translate, ActivationKey, ContentView, Organization, CurrentOrganization) {

        $scope.editContentView = false;
        $scope.editEnvironment = false;
        $scope.disableEnvironmentSelection = false;
        $scope.selectionRequired = true;
        $scope.environments = [];

        $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

        $scope.$on('activationKey.loaded', function () {
            $scope.originalEnvironment = $scope.activationKey.environment;
        });

        $scope.$watch('activationKey.environment', function (environment) {
            if ($scope.originalEnvironment) {
                if (environment) {
                    if (environment.id !== $scope.originalEnvironment.id) {
                        $scope.editContentView = true;
                        $scope.disableEnvironmentSelection = true;
                    }
                } else {
                    $scope.disableEnvironmentSelection = true;
                    $scope.editContentView = false;
                    $scope.activationKey["environment_id"] = null;
                    $scope.resetContentView($scope.activationKey);
                }
            } else if (environment) {
                $scope.editEnvironment = true;
                $scope.editContentView = true;
                $scope.disableEnvironmentSelection = true;
            }
        });

        $scope.cancelContentViewUpdate = function () {
            if ($scope.editContentView) {
                $scope.editContentView = false;
                $scope.editEnvironment = false;
                $scope.selectionRequired = false;
                $scope.activationKey.environment = $scope.originalEnvironment;
                $scope.disableEnvironmentSelection = false;
            }
        };

        $scope.saveContentView = function (activationKey) {
            $scope.editContentView = false;
            $scope.editEnvironment = false;
            $scope.save(activationKey).then(function (actKey) {
                $scope.originalEnvironment = actKey.environment;
                $scope.resetEnvironmentPathSelector(activationKey);
            });
            $scope.disableEnvironmentSelection = false;
        };

        $scope.resetEnvironmentPathSelector = function (activationKey) {
            // reset "selected" in the environment widget.
            _.each($scope.environments, function (environmentPath) {
                _.each(environmentPath, function (individualEnv) {
                    if (activationKey["environment_id"] !== individualEnv.id) {
                        delete individualEnv.selected;
                    } else {
                        individualEnv.selected = true;
                    }
                });
            });
        };

        $scope.resetEnvironment = function (activationKey) {
            delete activationKey.environment;
        };

        $scope.resetContentView = function (activationKey) {
            activationKey["content_view_id"] = null;
            activationKey["content_view"] = null;
            $scope.saveContentView(activationKey);
        };

        $scope.releaseVersions = function () {
            var deferred = $q.defer();

            ActivationKey.releaseVersions({ id: $scope.activationKey.id }, function (response) {
                deferred.resolve(response.results);
            });

            return deferred.promise;
        };

        $scope.clearReleaseVersion = function () {
            $scope.activationKey['release_version'] = '';
            $scope.save($scope.activationKey);
        };

        $scope.clearServiceLevel = function () {
            $scope.activationKey['service_level'] = '';
            $scope.save($scope.activationKey);
        };

        $scope.clearRole = function () {
            $scope.activationKey['purpose_role'] = '';
            $scope.save($scope.activationKey);
        };

        $scope.clearUsage = function () {
            $scope.activationKey['purpose_usage'] = '';
            $scope.save($scope.activationKey);
        };

        $scope.clearAddOns = function () {
            $scope.activationKey['purpose_addons'] = [];
            $scope.save($scope.activationKey);
        };

        $scope.contentViews = function () {
            var deferred = $q.defer();

            ContentView.queryUnpaged({ 'environment_id': $scope.activationKey.environment.id }, function (response) {
                deferred.resolve(response.results);
            });

            return deferred.promise;
        };
    }]
);
