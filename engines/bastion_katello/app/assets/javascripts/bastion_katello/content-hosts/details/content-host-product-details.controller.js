/**
 * Copyright 2013-2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostProductDetailsController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentHost
 */
angular.module('Bastion.content-hosts').controller('ContentHostProductDetailsController',
    ['$scope', 'translate', 'ContentHost',
    function ($scope, translate, ContentHost) {

        $scope.expanded = true;
        $scope.details = null;

        $scope.productDetails = function (product) {
            var override;

            if ($scope.details === null) {
                $scope.details = product;
                angular.forEach($scope.details['available_content'], function (content) {
                    override = _.findWhere($scope.contentHost["content_overrides"],
                                           {"contentLabel": content.content.label, name: "enabled"});
                    if (override === undefined) {
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
                    {name: $scope.getEnabledText(null, 1), id: 1},
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
                ContentHost.contentOverride({id: $scope.contentHost.uuid},
                        {'content_override': {'content_label': content.content.label,
                                              name: "enabled"}
                        },
                        function () {
                            $scope.success(content);
                        },
                        $scope.error);
            } else {
                ContentHost.contentOverride({id: $scope.contentHost.uuid},
                        {'content_override': { 'content_label': content.content.label,
                                               name: "enabled",
                                               value: content.overrideEnabled}
                        },
                        function () {
                            $scope.success(content);
                        },
                        $scope.error);
            }
        };
    }]
);
