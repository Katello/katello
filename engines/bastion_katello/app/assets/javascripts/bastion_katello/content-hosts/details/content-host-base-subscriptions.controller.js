/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostBaseSubscriptionsController
 *
 * @requires $scope
 * @requires translate
 * @requires CurrentOrganization
 * @requires Subscription
 * @requires ContentHost
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostBaseSubscriptionsController',
    ['$scope', '$location', 'translate', 'CurrentOrganization', 'Subscription', 'ContentHost',
    function ($scope, $location, translate, CurrentOrganization, Subscription, ContentHost) {

        function success() {
            $scope.subscription.workingMode = false;
            $scope.$parent.successMessages = [translate('Successfully updated subscriptions.')];
            $scope.contentHost.$get();
        }

        function failure() {
            $scope.subscription.workingMode = false;
            $scope.$parent.errorMessages = [translate('An error occurred trying to auto-attach subscriptions.  Please check your log for further information.')];
        }

        $scope.subscription = {
            workingMode: false
        };

        $scope.autoAttachSubscriptions = function () {
            $scope.subscription.workingMode = true;
            ContentHost.refreshSubscriptions({uuid: $scope.contentHost.uuid}, success, failure);
        };

    }]
);
