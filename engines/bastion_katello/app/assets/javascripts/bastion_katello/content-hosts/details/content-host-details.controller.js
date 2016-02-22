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
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDetailsController',
    ['$scope', '$state', '$q', 'translate', 'Host', 'Organization', 'CurrentOrganization', 'MenuExpander',
    function ($scope, $state, $q, translate, Host, Organization, CurrentOrganization, MenuExpander) {
        $scope.menuExpander = MenuExpander;
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.panel = {loading: true};

        $scope.host = Host.get({id: $scope.$stateParams.hostId}, function () {
            $scope.panel.loading = false;
        });

        // @TODO begin hack for content and subscript facets
        // see http://projects.theforeman.org/issues/13763
        $scope.saveContentFacet = function (host) {
            host['content_facet_attributes'] = {
                id: host.content.id,
                'content_view_id': host.content.content_view.id,
                'lifecycle_environment_id': host.content.lifecycle_environment.id
            };
            return $scope.save(host);
        };

        $scope.saveSubscriptionFacet = function (host) {
            host['subscription_facet_attributes'] = {
                id: host.subscription.id,
                autoheal: host.subscription.autoheal,
                'service_level': host.subscription.service_level
            };
            return $scope.save(host);
        };
        // @TODO end hack

        $scope.save = function (host) {
            var deferred = $q.defer();

            // TODO begin hack needed to use the foreman host API, see the following bugs:
            // http://projects.theforeman.org/issues/13622
            // http://projects.theforeman.org/issues/13669
            // http://projects.theforeman.org/issues/13670
            // http://projects.theforeman.org/issues/13672
            // http://projects.theforeman.org/issues/13759

            var whitelistedHostObject = {},
                whitelist = [
                    "name",
                    "description",
                    "content_facet_attributes",
                    "subscription_facet_attributes"
                ];

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
            // TODO end hack

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
    }]
);
