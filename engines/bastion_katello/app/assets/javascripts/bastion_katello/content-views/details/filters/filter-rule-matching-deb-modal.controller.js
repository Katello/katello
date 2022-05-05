/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FilterRuleMatchingDebModal
 *
 * @requires $scope
 * @requires $location
 * @requires $uibModalInstance
 * @requires filterRuleId
 * @requires Deb
 * @requires Nutupane
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing matching filter rule modal
 */
angular.module('Bastion.content-views').controller('FilterRuleMatchingDebModal',
    ['$scope', '$location', '$uibModalInstance', 'filterRuleId', 'Deb', 'Nutupane', 'CurrentOrganization',
        function ($scope, $location, $uibModalInstance, filterRuleId, Deb, Nutupane, CurrentOrganization) {

            var nutupane, params = {
              'organization_id': CurrentOrganization,
              'content_view_filter_rule_id': filterRuleId,
              'search': $location.search().search || "",
              'paged': true
            };

            nutupane = $scope.nutupane = new Nutupane(Deb, params);
            $scope.nutupane.setSearchKey('filterRule' + filterRuleId + "Debs");
            $scope.nutupane.setTableName('filterRule' + filterRuleId + "DebsTable");
            $scope.table = nutupane.table;

            $scope.cancel = function () {
                $uibModalInstance.close();
            };
        }
    ]
);
