/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDetailsController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
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
    ['$scope', '$q', 'translate', 'HostSubscription', 'ContentView', 'Organization', 'CurrentOrganization', 'ContentHostsHelper',
    function ($scope, $q, translate, HostSubscription, ContentView, Organization, CurrentOrganization, ContentHostsHelper) {
        function doubleColonNotationToObject(dotString) {
            var doubleColonObject = {}, tempObject, parts, part, key, property;
            for (property in dotString) {
                if (dotString.hasOwnProperty(property)) {
                    tempObject = doubleColonObject;
                    parts = property.split('::');
                    key = parts.pop();
                    while (parts.length) {
                        part = parts.shift();
                        tempObject = tempObject[part] = tempObject[part] || {};
                    }
                    tempObject[key] = dotString[property];
                }
            }
            return doubleColonObject;
        }

        $scope.host.$promise.then(function (host) {
            $scope.hostFactsAsObject = doubleColonNotationToObject(host.facts);
            if (host.hasContent()) {
                $scope.originalEnvironment = host.content_facet_attributes.lifecycle_environment;
            }
        });

        $scope.showVersionAlert = false;
        $scope.editContentView = false;
        $scope.disableEnvironmentSelection = false;
        $scope.environments = [];

        $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

        $scope.$watch('host.content_facet_attributes.lifecycle_environment', function (environment) {
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
                $scope.host.content_facet_attributes['lifecycle_environment'] = $scope.originalEnvironment;
                $scope.disableEnvironmentSelection = false;
            }
        };

        $scope.saveContentView = function (host) {
            $scope.editContentView = false;

            $scope.saveContentFacet(host).then(function (response) {
                $scope.originalEnvironment = response.content_facet_attributes.lifecycle_environment;
            });
            $scope.disableEnvironmentSelection = false;
        };

        $scope.releaseVersions = function () {
            var deferred = $q.defer();

            HostSubscription.releaseVersions({ id: $scope.host.id }, function (response) {
                if (response.total === 0) {
                    $scope.showVersionAlert = true;
                }
                deferred.resolve(response.results);
            });

            return deferred.promise;
        };

        $scope.clearReleaseVersion = function () {
            $scope.host.subscription_facet_attributes['release_version'] = '';
            $scope.saveSubscriptionFacet($scope.host);
        };

        $scope.clearRole = function () {
            $scope.host.subscription_facet_attributes['purpose_role'] = '';
            $scope.saveSubscriptionFacet($scope.host);
        };

        $scope.clearUsage = function () {
            $scope.host.subscription_facet_attributes['purpose_usage'] = '';
            $scope.saveSubscriptionFacet($scope.host);
        };

        $scope.clearAddOns = function () {
            $scope.host.subscription_facet_attributes['purpose_addons'] = [];
            $scope.saveSubscriptionFacet($scope.host);
        };

        $scope.clearServiceLevel = function () {
            $scope.host.subscription_facet_attributes['service_level'] = '';
            $scope.saveSubscriptionFacet($scope.host);
        };

        $scope.contentViews = function () {
            var deferred = $q.defer();

            ContentView.queryUnpaged({ 'environment_id': $scope.host.content_facet_attributes.lifecycle_environment.id}, function (response) {
                deferred.resolve(response.results);
                $scope.contentViews = response.results;
            });

            return deferred.promise;
        };

        $scope.getActivationKeyLink = function (activationKey) {
            return '/activation_keys!=&panel=activation_key_%s&panelpage=edit'.replace('%s', activationKey.id);
        };

        $scope.virtualGuestIds = function (host) {
            var ids = [];
            if (host && host.subscription_facet_attributes) {
                angular.forEach(host.subscription_facet_attributes['virtual_guests'], function (guest) {
                    ids.push('name = %s'.replace('%s', guest.name));
                });
            }

            return ids.join(" or ");
        };

        $scope.convertMemToGB = ContentHostsHelper.convertMemToGB;

        $scope.virtual = function (virt) {
            return (virt === true || virt === 'true');
        };

        $scope.hostRam = function (host) {
            if (host && host.facts) {
                return host.facts["memory::memtotal"] ? $scope.convertMemToGB(host.facts["memory::memtotal"]) : "";
            }
        };
    }]
);
