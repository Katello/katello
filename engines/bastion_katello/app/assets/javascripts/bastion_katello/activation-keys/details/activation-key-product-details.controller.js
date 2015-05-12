/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyProductDetailsController
 *
 * @requires $scope
 * @requires translate
 * @requires ActivationKey
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyProductDetailsController',
    ['$scope', 'translate', 'ActivationKey',
    function ($scope, translate, ActivationKey) {

        $scope.expanded = true;
        $scope.details = null;

        $scope.productDetails = function (product) {
            var override;

            if ($scope.details === null) {
                $scope.details = product;
                angular.forEach($scope.details['available_content'], function (content) {
                    override = _.findWhere($scope.activationKey["content_overrides"],
                                           {"contentLabel": content.content.label, name: "enabled"});
                    if (angular.isUndefined(override)) {
                        content.overrideEnabled = null;
                    } else {
                        content.overrideEnabled = Number(override.value);
                    }
                    content.enabledText = $scope.getEnabledText(content.enabled, content.overrideEnabled);
                });
            }
        };

        $scope.overrideEnableChoices = function (content) {
            var choices;
            if (content.enabled === true) {
                choices = [
                    {name: $scope.getEnabledText(content.enabled, null), id: null},
                    {name: $scope.getEnabledText(null, 0), id: 0}
                ];
            } else {
                choices = [
                    {name: $scope.getEnabledText(content.enabled, null), id: null},
                    {name: $scope.getEnabledText(null, 1), id: 1}
                ];
            }
            return choices;
        };

        $scope.getEnabledText = function (enabled, overrideEnabled) {
            var enabledText;

            if (overrideEnabled === null) {
                enabledText = enabled ? translate("Yes (Default)") : translate("No (Default)");
            } else if (overrideEnabled === 1) {
                enabledText = translate("Override to Yes");
            } else {
                enabledText = translate("Override to No");
            }

            return enabledText;
        };

        $scope.success = function (content) {
            content.enabledText = $scope.getEnabledText(content.enabled, content.overrideEnabled);
            $scope.successMessages.push(translate('Updated override to "%x".')
                    .replace('%x', content.enabledText));
        };

        $scope.error = function (error) {
            $scope.errorMessages.push(error.data.errors);
        };

        $scope.saveContentOverride = function (content) {
            if (content.overrideEnabled === null) {
                ActivationKey.contentOverride({id: $scope.activationKey.id},
                        {'content_override': {'content_label': content.content.label,
                                              value: 'default'}
                        },
                        function (response) {
                            $scope.success(content);
                            $scope.setActivationKey(response);
                        },
                        $scope.error);
            } else {
                ActivationKey.contentOverride({id: $scope.activationKey.id},
                        {'content_override': { 'content_label': content.content.label,
                                               value: content.overrideEnabled}
                        },
                        function (response) {
                            $scope.success(content);
                            $scope.setActivationKey(response);
                        },
                        $scope.error);
            }
        };
    }]
);
