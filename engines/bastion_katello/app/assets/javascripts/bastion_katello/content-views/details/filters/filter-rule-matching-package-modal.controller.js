/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FilterRuleMatchingPackageModal
 *
 * @requires $scope
 * @requires $location
 * @requires $uibModalInstance
 * @requires filterRuleId
 * @requires Package
 * @requires Nutupane
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing matching filter rule modal
 */
angular.module('Bastion.content-views').controller('FilterRuleMatchingPackageModal',
    ['$scope', '$location', '$uibModalInstance', 'filterRuleId', 'Package', 'Nutupane', 'CurrentOrganization',
        function ($scope, $location, $uibModalInstance, filterRuleId, Package, Nutupane, CurrentOrganization) {

            var nutupane, params = {
              'organization_id': CurrentOrganization,
              'content_view_filter_rule_id': filterRuleId,
              'search': $location.search().search || "",
              'paged': true
            };

            nutupane = $scope.nutupane = new Nutupane(Package, params);
            $scope.nutupane.setSearchKey('filterRule' + filterRuleId + "Packages");
            $scope.nutupane.setTableName('filterRule' + filterRuleId + "PackagesTable");
            $scope.table = nutupane.table;

            $scope.cancel = function () {
                $uibModalInstance.close();
            };
        }
    ]
);
