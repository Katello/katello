/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostProductsController
 *
 * @requires $scope
 * @requires translate
 * @requires HostSubscription
 *
 * @description
 *   Provides the functionality for the content-host products action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostProductsController',
    ['$scope', 'translate', 'HostSubscription',
    function ($scope, translate, HostSubscription) {
        var defaultOverride = "default",
            enabledOverride = "1",
            disabledOverride = "0";

        function processOverrides(overrides) {
            var products = {};

            angular.forEach(overrides, function (override) {
                if (angular.isUndefined(products[override.product.name])) {
                    products[override.product.name] = [];
                }

                override.enabledText = $scope.getEnabledText(override.enabled, override.enabled_override);
                products[override.product.name].push(override);
            });

            $scope.products = products;
            $scope.displayArea.isAvailableContent = Object.keys(products).length !== 0;
            $scope.displayArea.working = false;
        }

        $scope.getEnabledText = function (enabled, overrideEnabled) {
            var enabledText;
            overrideEnabled = overrideEnabled + "";

            if (overrideEnabled === defaultOverride) {
                enabledText = enabled ? translate("Yes (Default)") : translate("No (Default)");
            } else if (overrideEnabled === enabledOverride) {
                enabledText = translate("Override to Yes");
            } else {
                enabledText = translate("Override to No");
            }

            return enabledText;
        };

        $scope.overrideEnableChoices = function (override) {
            var choices;
            if (override.enabled === true) {
                choices = [
                    {name: $scope.getEnabledText(true, defaultOverride), id: "default"},
                    {name: $scope.getEnabledText(null, 0), id: disabledOverride}
                ];
            } else {
                choices = [
                    {name: $scope.getEnabledText(false, defaultOverride), id: "default"},
                    {name: $scope.getEnabledText(null, 1), id: enabledOverride}
                ];
            }
            return choices;
        };

        $scope.success = function (content) {
            content.enabledText = $scope.getEnabledText(content.enabled, content.enabled_override);
            $scope.successMessages.push(translate('Updated override for %y to "%x".')
                    .replace('%x', content.enabledText).replace("%y", content.content.name));
        };

        $scope.error = function (error) {
            $scope.errorMessages.push(error.data.errors);
        };

        $scope.saveContentOverride = function (content) {
            var params = {'content_label': content.content.label,
                           name: "enabled",
                           value: content.enabled_override
                         };

            HostSubscription.contentOverride({id: $scope.host.id}, params,
                    function () {
                        $scope.success(content);
                    },
                    $scope.error);
        };

        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.displayArea = { working: true, isAvailableContent: false };

        HostSubscription.productContent({id: $scope.$stateParams.hostId, 'full_result': true,
                              'include_available_content': true }, function (response) {
            processOverrides(response.results);
        });
    }]
);
