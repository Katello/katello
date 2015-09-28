/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostSubscriptionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Subscription
 * @requires ContentHost
 * @requires SubscriptionsHelper
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostSubscriptionsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'Subscription', 'ContentHost', 'SubscriptionsHelper',
    function ($scope, $location, translate, Nutupane, CurrentOrganization, Subscription, ContentHost, SubscriptionsHelper) {

        var params = {
            'system_id': $scope.$stateParams.contentHostId,
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_order': 'ASC'
        };

        $scope.contentNutupane = new Nutupane(Subscription, params);
        $scope.detailsTable = $scope.contentNutupane.table;

        $scope.contentNutupane.masterOnly = true;
        $scope.isRemoving = false;

        $scope.groupedSubscriptions = {};
        $scope.$watch('detailsTable.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.disableRemoveButton = function () {
            return $scope.detailsTable.numSelected === 0 || $scope.isRemoving;
        };

        $scope.removeSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptions($scope.detailsTable);

            $scope.isRemoving = true;
            ContentHost.removeSubscriptions({uuid: $scope.contentHost.uuid, 'subscriptions': selected}, function () {
                ContentHost.get({id: $scope.$stateParams.contentHostId}, function (host) {
                    $scope.$parent.contentHost = host;
                    $scope.contentNutupane.table.selectAll(false);
                    $scope.contentNutupane.refresh();
                    $scope.successMessages.push(translate("Successfully removed %s subscriptions.").replace('%s', selected.length));
                    $scope.isRemoving = false;
                });
            }, function (response) {
                $scope.isRemoving = false;
                $scope.errorMessages.push(translate("An error occurred removing the subscriptions.") + response.data.displayMessage);
            });
        };
    }
]);
