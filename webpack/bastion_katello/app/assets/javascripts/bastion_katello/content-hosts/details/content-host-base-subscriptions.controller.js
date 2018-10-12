/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostBaseSubscriptionsController
 *
 * @requires $scope
 * @requires translate
 * @requires CurrentOrganization
 * @requires Subscription
 * @requires Nutupane
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostBaseSubscriptionsController',
    ['$scope', '$location', 'translate', 'CurrentOrganization', 'Subscription', 'HostSubscription', 'Notification',
    function ($scope, $location, translate, CurrentOrganization, Subscription, HostSubscription, Notification) {

        function success() {
            $scope.subscription.workingMode = false;
            Notification.setSuccessMessage(translate('Successfully updated subscriptions.'));
            $scope.host.$get();
        }

        function failure() {
            $scope.subscription.workingMode = false;
            Notification.setErrorMessage(translate('An error occurred trying to auto-attach subscriptions.  Please check your log for further information.'));
        }

        $scope.subscription = {
            workingMode: false
        };

        $scope.autoAttachSubscriptions = function () {
            $scope.subscription.workingMode = true;
            HostSubscription.autoAttach({id: $scope.host.id}, success, failure);
        };

    }]
);
