/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires Organization
 * @requires CurrentOrganization
 * @requires MenuExpander
 * @requires ApiErrorHandler
 * @requires deleteHostOnUnregister
 * @requires ContentHostsHelper
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDetailsController',
    ['$scope', '$state', '$q', 'translate', 'Host', 'HostSubscription', 'Organization', 'CurrentOrganization', 'Notification', 'MenuExpander', 'ApiErrorHandler', 'deleteHostOnUnregister', 'ContentHostsHelper',
    function ($scope, $state, $q, translate, Host, HostSubscription, Organization, CurrentOrganization, Notification, MenuExpander, ApiErrorHandler, deleteHostOnUnregister, ContentHostsHelper) {
        $scope.menuExpander = MenuExpander;

        $scope.getHostStatusIcon = ContentHostsHelper.getHostStatusIcon;
        $scope.getHostPurposeStatusIcon = ContentHostsHelper.getHostPurposeStatusIcon;

        $scope.organization = Organization.get({id: CurrentOrganization}, function(org) {
            $scope.purposeAddonsCount += org.system_purposes.addons.length;
        });

        $scope.defaultUsages = ['Production', 'Development/Test', 'Disaster Recovery'];
        $scope.defaultRoles = ['Red Hat Enterprise Linux Server', 'Red Hat Enterprise Linux Workstation', 'Red Hat Enterprise Linux Compute Node'];
        $scope.defaultServiceLevels = ['Self-Support', 'Standard', 'Premium'];

        $scope.purposeAddonsCount = 0;

        $scope.panel = {
            error: false,
            loading: true
        };

        $scope.host = Host.get({id: $scope.$stateParams.hostId}, function (host) {
            host.unregisterDelete = !host.hasSubscription() || deleteHostOnUnregister;
            host.deleteHostOnUnregister = deleteHostOnUnregister;
            $scope.panel.loading = false;
            $scope.purposeAddonsCount += host.subscription_facet_attributes.purpose_addons.length;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        // @TODO begin hack for content and subscript facets
        // see http://projects.theforeman.org/issues/13763
        $scope.saveContentFacet = function (host) {
            var newHost = {id: host.id};
            newHost['content_facet_attributes'] = {
                id: host.content_facet_attributes.id,
                'content_view_id': host.content_facet_attributes.content_view.id,
                'lifecycle_environment_id': host.content_facet_attributes.lifecycle_environment.id
            };
            return $scope.save(newHost, true);
        };

        $scope.saveSubscriptionFacet = function (host) {
            var newHost = {id: host.id};

            newHost['subscription_facet_attributes'] = {
                id: host.subscription_facet_attributes.id,
                autoheal: host.subscription_facet_attributes.autoheal,
                'purpose_role': host.subscription_facet_attributes.purpose_role,
                'purpose_usage': host.subscription_facet_attributes.purpose_usage,
                'service_level': host.subscription_facet_attributes.service_level,
                'release_version': host.subscription_facet_attributes.release_version
            };

            if ($scope.purposeAddonsList) {
                newHost['subscription_facet_attributes']['purpose_addons'] = _.chain($scope.purposeAddonsList).filter(function(addOn) {
                    return addOn.selected;
                }).map(function(addOn) {
                    return addOn.name;
                }).value();
            }

            return $scope.save(newHost, true);
        };
        // @TODO end hack

        $scope.save = function (host, saveFacets) {
            var deferred = $q.defer();

            // @TODO begin hack needed to use the foreman host API, see the following bugs:
            // http://projects.theforeman.org/issues/13622
            // http://projects.theforeman.org/issues/13669
            // http://projects.theforeman.org/issues/13670
            // http://projects.theforeman.org/issues/13672
            // http://projects.theforeman.org/issues/13759

            var whitelistedHostObject = {},
                whitelist = [
                    "name",
                    "comment"
                ];

            if (saveFacets) {
                whitelist.push("content_facet_attributes");
                whitelist.push("subscription_facet_attributes");
            }

            angular.forEach(whitelist, function (key) {
                whitelistedHostObject[key] = host[key];
            });

            Host.update({id: host.id, host: whitelistedHostObject}, function (response) {
                deferred.resolve(response);
                $scope.host = response;
                Notification.setSuccessMessage(translate('Save Successful.'));
            }, function (response) {
                deferred.reject(response);
                _.each(response.data.error.full_messages, function (errorMessage) {
                    Notification.setErrorMessage(translate("An error occurred saving the Content Host: ") + errorMessage);
                });
            });
            // @TODO end hack

            return deferred.promise;
        };

        $scope.transitionTo = function (state, params) {
            var hostId = $scope.$stateParams.hostId;

            if ($scope.host && $scope.host.id) {
                hostId = $scope.host.id;
            }

            if (hostId) {
                params = params ? params : {};
                params.hostId = hostId;
                $state.transitionTo(state, params);
                return true;
            }
            return false;
        };

        $scope.serviceLevels = function () {
            return $scope.organization.$promise.then(function(org) {
                return _.union(org.service_levels, $scope.defaultServiceLevels);
            });
        };

        $scope.purposeRoles = function () {
            return $scope.organization.$promise.then(function(org) {
                var roles = org.system_purposes.roles;
                var role = $scope.host.subscription_facet_attributes.purpose_role;
                if (role && !_.includes(roles, role)) {
                    roles.push(role);
                }
                return _.union(roles, $scope.defaultRoles);
            });
        };

        $scope.purposeUsages = function () {
            return $scope.organization.$promise.then(function(org) {
                var usages = org.system_purposes.usage;
                var usage = $scope.host.subscription_facet_attributes.purpose_usage;
                if (usage && !_.includes(usages, usage)) {
                    usages.push(usage);
                }
                return _.union(usages, $scope.defaultUsages);
            });
        };

        $scope.purposeAddons = function () {
            var purposeAddons;
            var addOns;

            return $scope.organization.$promise.then(function(org) {
                $scope.purposeAddonsList = [];
                addOns = org.system_purposes.addons;

                purposeAddons = $scope.host.subscription_facet_attributes.purpose_addons;
                angular.forEach(purposeAddons, function(addOn) {
                    if (addOn && !_.includes(addOns, addOn)) {
                        addOns.push(addOn);
                    }
                });

                angular.forEach(addOns, function (addOn) {
                    $scope.purposeAddonsList.push({"name": addOn, "selected": purposeAddons.indexOf(addOn) > -1});
                });

                return $scope.purposeAddonsList;
            });
        };

        $scope.unregisterContentHost = function (host) {
            var errorHandler = function (response) {
                host.deleting = false;
                Notification.setErrorMessage(translate('An error occured: %s').replace('%s', response.data.displayMessage));
            };
            host.deleting = true;

            if (host.unregisterDelete) {
                host.$delete(function () {
                    host.deleting = false;
                    Notification.setSuccessMessage(translate('Host %s has been deleted.').replace('%s', host.name));
                    $scope.transitionTo('content-hosts');
                }, errorHandler);
            } else {
                HostSubscription.delete({id: host.id}, function () {
                    host.deleting = false;
                    Notification.setSuccessMessage(translate('Host %s has been unregistered.').replace('%s', host.name));
                    $scope.transitionTo('content-hosts');
                }, errorHandler);
            }
        };
    }]
);
