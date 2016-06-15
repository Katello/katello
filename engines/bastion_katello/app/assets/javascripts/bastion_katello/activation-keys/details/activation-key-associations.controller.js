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
 *
 * @description
 *   Provides the functionality for activation key associations.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyAssociationsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'ActivationKey', 'ContentHostsHelper', 'CurrentOrganization', 'Host',
    function ($scope, $location, translate, Nutupane, ActivationKey, ContentHostsHelper, CurrentOrganization, Host) {
        var contentHostsNutupane, params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'page': 1,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        $scope.table.working = true;

        if ($scope.contentHosts) {
            $scope.table.working = false;
        }

        contentHostsNutupane = new Nutupane(Host, params);
        contentHostsNutupane.searchTransform = function (term) {
            var searchQuery, addition = "activation_key_id=" + $scope.$stateParams.activationKeyId;
            if (term === "" || angular.isUndefined(term)) {
                searchQuery = addition;
            } else {
                searchQuery = term + " and " + addition;
            }
            return searchQuery;
        };

        contentHostsNutupane.masterOnly = true;
        $scope.detailsTable = contentHostsNutupane.table;

        $scope.activationKey.$promise.then(function () {
            contentHostsNutupane.setParams(params);
            contentHostsNutupane.load();
        });

        $scope.getHostStatusIcon = ContentHostsHelper.getHostStatusIcon;

        $scope.memory = ContentHostsHelper.memory;
    }]
);
