/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyAssociationsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires ActivationKey
 * @requires ContentHostsHelper
 * @requires CurrentOrganization
 * @requires newHostDetailsUI
 *
 * @description
 *   Provides the functionality for activation key associations.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyAssociationsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'ActivationKey', 'ContentHostsHelper', 'CurrentOrganization', 'Host', 'newHostDetailsUI',
    function ($scope, $location, translate, Nutupane, ActivationKey, ContentHostsHelper, CurrentOrganization, Host, newHostDetailsUI) {
        var contentHostsNutupane, nutupaneParams, params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'page': 1,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        nutupaneParams = {
            'disableAutoLoad': true
        };

        contentHostsNutupane = new Nutupane(Host, params, undefined, nutupaneParams);
        $scope.controllerName = 'hosts';
        contentHostsNutupane.searchTransform = function (term) {
            var searchQuery, addition = "activation_key_id=" + $scope.$stateParams.activationKeyId;
            if (term === "" || angular.isUndefined(term)) {
                searchQuery = addition;
            } else {
                searchQuery = term + " and " + addition;
            }
            return searchQuery;
        };

        contentHostsNutupane.primaryOnly = true;
        contentHostsNutupane.setSearchKey('contentHostSearch');

        $scope.table = contentHostsNutupane.table;
        $scope.table.working = true;
        $scope.newHostDetailsUI = newHostDetailsUI;

        if ($scope.contentHosts) {
            $scope.table.working = false;
        }

        $scope.activationKey.$promise.then(function () {
            contentHostsNutupane.setParams(params);
            contentHostsNutupane.load();
        });

        $scope.getHostStatusIcon = ContentHostsHelper.getHostStatusIcon;

        $scope.memory = ContentHostsHelper.memory;
    }]
);
