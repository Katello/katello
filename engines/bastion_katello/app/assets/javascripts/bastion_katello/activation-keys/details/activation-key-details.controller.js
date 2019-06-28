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
 *
 * @description
 *   Provides the functionality for the activation key details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyDetailsController',
    ['$scope', '$state', '$q', 'translate', 'ActivationKey', 'Organization', 'CurrentOrganization', 'Notification', 'ApiErrorHandler',
    function ($scope, $state, $q, translate, ActivationKey, Organization, CurrentOrganization, Notification, ApiErrorHandler) {
        $scope.defaultRoles = ['Red Hat Enterprise Linux Server', 'Red Hat Enterprise Linux Workstation', 'Red Hat Enterprise Linux Compute Node'];
        $scope.defaultUsages = ['Production', 'Development/Test', 'Disaster Recovery'];

        $scope.purposeAddonsCount = 0;

        $scope.organization = Organization.get({id: CurrentOrganization}, function(org) {
            $scope.purposeAddonsCount += org.system_purposes.addons.length;
        });

        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.activationKey) {
            $scope.panel.loading = false;
        }

        $scope.activationKey = ActivationKey.get({id: $scope.$stateParams.activationKeyId}, function (activationKey) {
            $scope.$broadcast('activationKey.loaded', activationKey);
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.save = function (activationKey) {
            var deferred = $q.defer();

            activationKey.$update(function (response) {
                deferred.resolve(response);
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


        $scope.savePurposeAddons = function (key) {

            if ($scope.purposeAddonsList) {
                key['purpose_addons'] = _.chain($scope.purposeAddonsList).filter(function(addOn) {
                    return addOn.selected;
                }).map(function(addOn) {
                    return addOn.name;
                }).value();
            }

            return $scope.save(key);
        };


        $scope.purposeAddons = function () {
            var purposeAddons;
            var addOns;

            return $scope.organization.$promise.then(function(org) {
                $scope.purposeAddonsList = [];
                addOns = org.system_purposes.addons;

                purposeAddons = $scope.activationKey.purpose_addons;
                angular.forEach(purposeAddons, function(addOn) {
                    if (addOn && !_.includes(addOns, addOn)) {
                        addOns.push(addOn);
                    }
                });

                angular.forEach(addOns, function (addOn) {
                    $scope.purposeAddonsList.push({"name": addOn, "selected": purposeAddons.indexOf(addOn) > -1});
                });

                return $scope.purposeAddonsList;
            });
        };
    }]
);
