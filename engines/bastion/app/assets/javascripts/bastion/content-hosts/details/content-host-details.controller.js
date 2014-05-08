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
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires ContentHost
 * @requires Organization
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
                params.contentHostId  = contentHostId;
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
