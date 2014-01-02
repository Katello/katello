/**
 * Copyright 2013 Red Hat, Inc.
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
 * @name  Bastion.subscriptions.controller:ManifestImportController
 *
 * @requires $scope
 * @requires $q
 * @requires gettext
 * @requires CurrentOrganization
 * @requires Provider
 * @requires Organization
 *
 * @description
 *   Controls the import of a manifest.
 */
angular.module('Bastion.subscriptions').controller('ManifestImportController',
    ['$scope', '$q', 'gettext', 'CurrentOrganization', 'Provider', 'Organization',
    function ($scope, $q, gettext, CurrentOrganization, Provider, Organization) {

        $scope.uploadErrorMessages = [];
        $scope.organizationId = CurrentOrganization;
        $scope.progress = {uploading: false};
        $scope.showHistoryMoreLink = false;

        $scope.$on('$stateChangeSuccess', function (event, toState) {
            if (toState.name === 'subscriptions.manifest.import') {
                $scope.organization = Organization.get({id: CurrentOrganization});

                $q.all([$scope.provider.$promise, $scope.organization.$promise]).then(function () {
                    $scope.panel.loading = false;
                    initializeManifestDetails($scope.organization, $scope.provider);
                });
            }
        });

        $scope.save = function (provider) {
            var deferred = $q.defer();

            provider.$update(function (response) {
                deferred.resolve(response);
                $scope.saveSuccess = true;
                $scope.successMessages.push(gettext("Red Hat provider successfully updated."));
            }, function (response) {
                deferred.reject(response);
                $scope.saveError = true;
                $scope.errors = response.data.errors;
            });

            return deferred.promise;
        };

        $scope.deleteManifest = function (provider) {
            provider.$deleteManifest(function () {
                $scope.saveSuccess = true;
                $scope.successMessages.push(gettext("Manifest successfully deleted."));
                $scope.refreshTable();

                // setup us up the page again
                $scope.provider = Provider.get({id: $scope.$stateParams.providerId});
                $scope.organization = Organization.get({id: CurrentOrganization});
                $q.all([$scope.provider.$promise, $scope.organization.$promise]).then(function () {
                    initializeManifestDetails($scope.organization, $scope.provider);
                });
            }, function (response) {
                $scope.saveError = true;
                $scope.errors = response.data.errors;
            });
        };

        $scope.refreshManifest = function (provider) {
            provider.$refreshManifest(function () {
                $scope.saveSuccess = true;
                $scope.successMessages.push(gettext("Manifest successfully refreshed."));
                $scope.refreshTable();
                $scope.transitionTo('subscriptions.index');
            }, function (response) {
                $scope.saveError = true;
                $scope.errors = response.data.errors;
            });
        };

        function buildManifestLink(upstream) {
            var url = upstream['webUrl'],
                upstreamId = upstream['uuid'];

            if (!url.match(/\/$/)) {
                url = url + "/";
            }

            url += upstreamId;

            return url;
        }

        $scope.uploadManifest = function (content) {
            var returnData;

            if (content !== "Please wait...") {
                try {
                    returnData = JSON.parse(angular.element(content).html());
                } catch (err) {
                    returnData = content;
                }

                if (!returnData) {
                    returnData = content;
                }

                if (returnData !== null && returnData.errors === undefined) {
                    $scope.saveSuccess = true;
                    $scope.successMessages.push(gettext("Manifest successfully imported."));
                    $scope.refreshTable();
                    $scope.transitionTo('subscriptions.index');
                } else {
                    $scope.uploadErrorMessages = [gettext('Error during upload: ') + returnData.displayMessage];
                }

                $scope.progress.uploading = false;
            }
        };

        function initializeManifestDetails(organization, provider) {
            $scope.manifestStatuses = $scope.manifestHistory(provider);
            if ($scope.manifestStatuses.length > 4) {
                $scope.manifestStatuses = _.first($scope.manifestStatuses, 3);
                $scope.showHistoryMoreLink = true;
            }

            $scope.details = organization['owner_details'];
            $scope.upstream = $scope.details.upstreamConsumer;

            if (!_.isNull($scope.upstream)) {
                $scope.manifestLink = buildManifestLink($scope.upstream);
                $scope.manifestName = $scope.upstream["name"] || $scope.upstream["uuid"];
            }
        }

    }]
);
