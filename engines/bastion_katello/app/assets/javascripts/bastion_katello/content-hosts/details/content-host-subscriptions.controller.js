/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostSubscriptionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Subscription
 * @requires SubscriptionsHelper
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostSubscriptionsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'Subscription', 'Host', 'HostSubscription', 'SubscriptionsHelper',
    function ($scope, $location, translate, Nutupane, CurrentOrganization, Subscription, Host, HostSubscription, SubscriptionsHelper) {

        var params = {
            'organization_id': CurrentOrganization,
            'id': $scope.$stateParams.hostId,
            'search': $location.search().search || "",
            'sort_order': 'ASC'
        };

        $scope.contentNutupane = new Nutupane(HostSubscription, params);
        $scope.contentNutupane.table.initialLoad = false;
        $scope.detailsTable = $scope.contentNutupane.table;
        $scope.contentNutupane.masterOnly = true;
        $scope.isRemoving = false;

        $scope.groupedSubscriptions = {};
        $scope.$watch('detailsTable.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.contentNutupane.setParams(params);
        $scope.contentNutupane.load(true);

        $scope.disableRemoveButton = function () {
            return $scope.detailsTable.numSelected === 0 || $scope.isRemoving;
        };

        $scope.removeSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptions($scope.detailsTable);

            $scope.isRemoving = true;
            HostSubscription.removeSubscriptions({id: $scope.$stateParams.hostId, 'subscriptions': selected}, function () {
                Host.get({id: $scope.$stateParams.hostId}, function (host) {
                    $scope.$parent.host = host;
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
