/**
 * Copyright 2014 Red Hat, Inc.
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
 * @name  Bastion.content-hosts.controller:ContentHostDetailsController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires CustomInfo
 * @requires ContentHost
 * @requires ContentView
 * @requires Organization
 * @requires CurrentOrganization
 * @requires CurrentHostsHelper
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDetailsInfoController',
    ['$scope', '$q', 'translate', 'CustomInfo', 'ContentHost', 'ContentView', 'Organization', 'CurrentOrganization', 'ContentHostsHelper',
        function ($scope, $q, translate, CustomInfo, ContentHost, ContentView, Organization, CurrentOrganization, ContentHostsHelper) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        var customInfoErrorHandler = function (response) {
            $scope.errorMessages = response.data.errors;
        };

        $scope.showVersionAlert = false;
        $scope.editContentView = false;
        $scope.disableEnvironmentSelection = false;
        $scope.environments = [];

        $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

        $scope.contentHost.$promise.then(function () {
            $scope.contentHostFacts = dotNotationToObj($scope.contentHost.facts);
            populateExcludedFacts();
            $scope.originalEnvironment = $scope.contentHost.environment;
        });

        $scope.$watch('contentHost.environment', function (environment) {
            if (environment && $scope.originalEnvironment) {
                if (environment.id !== $scope.originalEnvironment.id) {
                    $scope.editContentView = true;
                    $scope.disableEnvironmentSelection = true;
                }
            }
        });

        $scope.cancelReleaseVersionUpdate = function () {
            $scope.showVersionAlert = false;
        };

        $scope.cancelContentViewUpdate = function () {
            if ($scope.editContentView) {
                $scope.editContentView = false;
                $scope.contentHost.environment = $scope.originalEnvironment;
                $scope.disableEnvironmentSelection = false;
            }
        };

        $scope.saveContentView = function (contentHost) {
            $scope.editContentView = false;
            $scope.save(contentHost).then(function (contentHost) {
                $scope.originalEnvironment = contentHost.environment;
            });
            $scope.disableEnvironmentSelection = false;
        };

        $scope.releaseVersions = function () {
            var deferred = $q.defer();

            ContentHost.releaseVersions({ id: $scope.contentHost.uuid }, function (response) {
                if (response.total === 0) {
                    $scope.showVersionAlert = true;
                }
                deferred.resolve(response.results);
            });

            return deferred.promise;
        };

        $scope.clearReleaseVersion = function () {
            $scope.contentHost['release_ver'] = '';
            $scope.save($scope.contentHost);
        };

        $scope.clearServiceLevel = function () {
            $scope.contentHost['service_level'] = '';
            $scope.save($scope.contentHost);
        };

        $scope.contentViews = function () {
            var deferred = $q.defer();

            ContentView.queryUnpaged({ 'environment_id': $scope.contentHost.environment.id}, function (response) {
                deferred.resolve(response.results);
                $scope.contentViews = response.results;
            });

            return deferred.promise;
        };

        $scope.saveCustomInfo = function (info) {
            return CustomInfo.update({
                id: $scope.contentHost.id,
                type: 'system',
                action: info.keyname
            }, {
                'custom_info': info
            },
            function () {
                $scope.successMessages = [translate("Successfully updated custom info.")];
            },
            customInfoErrorHandler);
        };

        $scope.addCustomInfo = function (info) {
            var success = function () {
                    $scope.contentHost.customInfo.push(info);
                    $scope.successMessages = [translate("Successfully saved custom info.")];
                };

            return CustomInfo.save({
                id: $scope.contentHost.id,
                type: 'system'
            }, {
                'custom_info': info
            },
            success,
            customInfoErrorHandler);
        };

        $scope.deleteCustomInfo = function (info) {
            var success = function () {
                    $scope.contentHost.customInfo = _.filter($scope.contentHost.customInfo, function (keyValue) {
                        return keyValue !== info;
                    }, this);
                    $scope.successMessages = [translate("Successfully removed custom info.")];
                };

            return CustomInfo.delete({
                id: $scope.contentHost.id,
                type: 'system',
                action: info.keyname
            },
            success,
            customInfoErrorHandler);
        };

        $scope.getActivationKeyLink = function (activationKey) {
            return '/activation_keys!=&panel=activation_key_%s&panelpage=edit'.replace('%s', activationKey.id);
        };

        $scope.getTemplateForType = function (value) {
            var template = 'content-hosts/details/views/partials/content-host-detail-value.html';
            if (typeof(value) === 'object') {
                template = 'content-hosts/details/views/partials/content-host-detail-object.html';
            }
            return template;
        };

        function dotNotationToObj(dotString) {
            var dotObject = {}, tempObject, parts, part, key;
            for (var property in dotString) {
                if (dotString.hasOwnProperty(property)) {
                    tempObject = dotObject;
                    parts = property.split('.');
                    key = parts.pop();
                    while (parts.length) {
                        part = parts.shift();
                        tempObject = tempObject[part] = tempObject[part] || {};
                    }
                    tempObject[key] = dotString[property];
                }
            }
            return dotObject;
        }

        function populateExcludedFacts() {
            $scope.advancedInfoLeft = {};
            $scope.advancedInfoRight = {};
            var index = 0;
            angular.forEach($scope.contentHostFacts, function (value, key) {
                if (index % 2 === 0) {
                    $scope.advancedInfoLeft[key] = value;
                } else {
                    $scope.advancedInfoRight[key] = value;
                }
                index = index + 1;
            });
            $scope.hasAdvancedInfo = Object.keys($scope.advancedInfoLeft).length > 0 ||
                Object.keys($scope.advancedInfoRight).length > 0;

        }

        $scope.memory = ContentHostsHelper.memory;

        $scope.virtualGuestIds = function (contentHost) {
            var ids = [];
            angular.forEach(contentHost['virtual_guests'], function (host) {
                ids.push('id:%s'.replace('%s', host.id));
            });

            return ids.join(" ");
        };
    }]
);
