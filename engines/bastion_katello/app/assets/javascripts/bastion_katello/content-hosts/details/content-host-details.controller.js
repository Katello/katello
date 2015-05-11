/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires ContentHost
 * @requires Organization
 * @requires CurrentOrganization
 * @requires MenuExpander
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDetailsController',
    ['$scope', '$state', '$q', 'translate', 'ContentHost', 'Organization', 'CurrentOrganization', 'MenuExpander',
    function ($scope, $state, $q, translate, ContentHost, Organization, CurrentOrganization, MenuExpander) {

        $scope.menuExpander = MenuExpander;
        $scope.successMessages = [];
        $scope.errorMessages = [];

        if ($scope.contentHost) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.contentHost = ContentHost.get({id: $scope.$stateParams.contentHostId}, function (contentHost) {
            $scope.$watch("contentHostTable.rows.length > 0", function () {
                $scope.contentHostTable.replaceRow(contentHost);
            });

            $scope.$broadcast('contentHost.loaded', contentHost);
            $scope.panel.loading = false;
        });

        $scope.save = function (contentHost) {
            var deferred = $q.defer();

            contentHost.$update(function (response) {
                deferred.resolve(response);
                $scope.successMessages.push(translate('Save Successful.'));
            }, function (response) {
                deferred.reject(response);
                _.each(response.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(translate("An error occurred saving the Content Host: ") + errorMessage);
                });
            });

            return deferred.promise;
        };

        $scope.transitionTo = function (state, params) {
            var contentHostId = $scope.$stateParams.contentHostId;

            if ($scope.contentHost && $scope.contentHost.uuid) {
                contentHostId = $scope.contentHost.uuid;
            }

            if (contentHostId) {
                params = params ? params : {};
                params.contentHostId = contentHostId;
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
