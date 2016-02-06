/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyAssociationsController
 *
 * @requires $scope
 * @requires translate
 * @requires ActivationKey
 * @requires ContentHostsHelper
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for activation key associations.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyAssociationsController',
    ['$scope', 'translate', 'ActivationKey', 'ContentHostsHelper', 'CurrentOrganization',
    function ($scope, translate, ActivationKey, ContentHostsHelper, CurrentOrganization) {

        if ($scope.contentHosts) {
            $scope.table.working = false;
        } else {
            $scope.table.working = true;
        }

        $scope.activationKey.$promise.then(function () {
            ActivationKey.contentHosts({id: $scope.activationKey.id, 'organization_id': CurrentOrganization },
                function (response) {
                    $scope.contentHosts = response.results;
                    $scope.table.working = false;
                });
        });

        $scope.getSubscriptionStatusColor = ContentHostsHelper.getSubscriptionStatusColor;

        $scope.memory = ContentHostsHelper.memory;
    }]
);
