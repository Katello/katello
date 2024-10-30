/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires ActivationKey
 * @requires CurrentOrganization
 * @requires Organization
 * @requires Notification
 * @requires ApiErrorHandler
 * @requires simpleContentAccessEnabled
 *
 * @description
 *   Provides the functionality for the activation key details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyDetailsController',
    ['$scope', '$state', '$q', 'translate', 'ActivationKey', 'Organization', 'CurrentOrganization', 'Notification', 'ApiErrorHandler', 'simpleContentAccessEnabled',
    function ($scope, $state, $q, translate, ActivationKey, Organization, CurrentOrganization, Notification, ApiErrorHandler, simpleContentAccessEnabled) {
        $scope.defaultRoles = ['Red Hat Enterprise Linux Server', 'Red Hat Enterprise Linux Workstation', 'Red Hat Enterprise Linux Compute Node'];
        $scope.defaultUsages = ['Production', 'Development/Test', 'Disaster Recovery'];

        $scope.simpleContentAccessEnabled = simpleContentAccessEnabled;

        $scope.organization = Organization.get({id: CurrentOrganization}, function() {
        });

        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.activationKey) {
            $scope.panel.loading = false;
        }

        $scope.autoAttachOptions = function () {
            return [
                {
                    id: true,
                    name: translate("Yes")
                },
                {
                    id: false,
                    name: translate("No")
                }
            ];
        };

        $scope.activationKey = ActivationKey.get({id: $scope.$stateParams.activationKeyId}, function (activationKey) {
            $scope.panel.loading = false;
            $scope.originalEnvironment = activationKey.environment;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.save = function (activationKey) {
            var deferred = $q.defer();

            activationKey.$update(function (response) {
                deferred.resolve(response);
                $scope.originalEnvironment = activationKey.environment;
                Notification.setSuccessMessage(translate('Activation Key updated'));
            }, function (response) {
                deferred.reject(response);
                Notification.setErrorMessage(translate("An error occurred saving the Activation Key: ") + response.data.displayMessage);
            });
            return deferred.promise;
        };

        $scope.setActivationKey = function (activationKey) {
            $scope.activationKey = activationKey;
        };

        $scope.removeActivationKey = function (activationKey) {
            activationKey.$delete(function () {
                $scope.transitionTo('activation-keys');
                Notification.setSuccessMessage(translate('Activation Key removed.'));
            }, function (response) {
                Notification.setErrorMessage(translate("An error occurred removing the Activation Key: ") + response.data.displayMessage);
            });
        };

        $scope.serviceLevels = function () {
            return $scope.organization.$promise.then(function(org) {
                return org.service_levels;
            });
        };

        $scope.purposeUsages = function () {
            return $scope.organization.$promise.then(function(org) {
                var usages = org.system_purposes.usage;
                var usage = $scope.activationKey.purpose_usage;
                if (usage && !_.includes(usages, usage)) {
                    usages.push(usage);
                }
                return _.union(usages, $scope.defaultUsages);
            });
        };

        $scope.purposeRoles = function () {
            return $scope.organization.$promise.then(function(org) {
                var roles = org.system_purposes.roles;
                var role = $scope.activationKey.purpose_role;
                if (role && !_.includes(roles, role)) {
                    roles.push(role);
                }
                return _.union(roles, $scope.defaultRoles);
            });
        };
    }]
);
