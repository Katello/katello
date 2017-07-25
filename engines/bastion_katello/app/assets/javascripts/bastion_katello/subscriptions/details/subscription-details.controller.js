/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:SubscriptionDetailsController
 *
 * @requires $scope
 * @requires translate
 * @requires Subscription
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the subscription details action pane.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionDetailsController',
    ['$scope', 'translate', 'Subscription', 'ApiErrorHandler',
    function ($scope, translate, Subscription, ApiErrorHandler) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.subscription) {
            $scope.panel.loading = false;
        }

        $scope.searchQuery = function (subscription) {
            return 'subscription_id="%s"'.replace('%s', subscription.id);
        };

        $scope.subscription = Subscription.get({id: $scope.$stateParams.subscriptionId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.subscriptionLimits = function (subscription) {
            var limits = [];

            if (subscription.sockets) {
                limits.push(translate("Sockets: %s").replace("%s", subscription.sockets));
            }
            if (subscription.cores) {
                limits.push(translate("Cores: %s").replace("%s", subscription.cores));
            }
            if (subscription.ram) {
                limits.push(translate("RAM: %s GB").replace("%s", subscription.ram));
            }

            if (limits.length > 0) {
                return limits.join(", ");
            }

            return "";
        };

        $scope.virtWhoToolTip = translate("If the virt-who field is Yes then the subscription requires the use of virt-who. Learn how to configure and use this tool in the <a href=\"https://access.redhat.com/documentation/en/red-hat-satellite/6.2/single/virtual-instances-guide/\">Virtual Instances Guide</a>.");
    }]
);
