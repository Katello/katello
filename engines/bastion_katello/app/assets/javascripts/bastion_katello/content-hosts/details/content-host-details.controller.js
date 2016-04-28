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
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDetailsController',
    ['$scope', '$state', '$q', 'translate', 'Host', 'HostSubscription', 'Organization', 'CurrentOrganization', 'GlobalNotification', 'MenuExpander', 'ApiErrorHandler',
    function ($scope, $state, $q, translate, Host, HostSubscription, Organization, CurrentOrganization, GlobalNotification, MenuExpander, ApiErrorHandler) {
        $scope.menuExpander = MenuExpander;
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.panel = {
            error: false,
            loading: true
        };

        $scope.host = Host.get({id: $scope.$stateParams.hostId}, function (host) {
            host.unregisterDelete = !host.hasSubscription(); //default to delete if no subscription
            $scope.panel.loading = false;
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
                'service_level': host.subscription_facet_attributes.service_level,
                'release_version': host.subscription_facet_attributes.release_version
            };
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
                $scope.successMessages.push(translate('Save Successful.'));
            }, function (response) {
                deferred.reject(response);
                _.each(response.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(translate("An error occurred saving the Content Host: ") + errorMessage);
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
            var deferred = $q.defer();

            Organization.get({id: CurrentOrganization}, function (organization) {
                deferred.resolve(organization['service_levels']);
            });

            return deferred.promise;
        };

        $scope.unregisterContentHost = function (host) {
            var errorHandler = function (response) {
                host.deleting = false;
                GlobalNotification.setErrorMessage(translate('An error occured: %s').replace('%s', response.data.displayMessage));
            };
            host.deleting = true;

            if (host.unregisterDelete) {
                host.$delete(function () {
                    host.deleting = false;
                    GlobalNotification.setSuccessMessage(translate('Host %s has been deleted.').replace('%s', host.name));
                    $scope.removeRow(host.id);
                    $scope.transitionTo('content-hosts.index');
                }, errorHandler);
            } else {
                HostSubscription.delete({id: host.id}, function () {
                    host.deleting = false;
                    GlobalNotification.setSuccessMessage(translate('Host %s has been unregistered.').replace('%s', host.name));
                    $scope.transitionTo('content-hosts.index');
                }, errorHandler);
            }
        };
    }]
);
