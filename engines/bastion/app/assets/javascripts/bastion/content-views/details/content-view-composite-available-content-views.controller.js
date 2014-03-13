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
 * @name  Bastion.content-views.controller:ContentViewCompositeAvailableContentViewsController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires ContentView
 *
 * @description
 *  Provides a nutupane for eligible content views to be included in the composite.
 */
angular.module('Bastion.content-views').controller('ContentViewCompositeAvailableContentViewsController',
    ['$scope', 'Nutupane', 'CurrentOrganization', 'ContentView',
        function ($scope, Nutupane, CurrentOrganization, ContentView) {
            var nutupane = new Nutupane(
                ContentView,
                {
                    'organization_id': CurrentOrganization,
                    'full_result': true
                },
                'compositeEligible'
            );

            $scope.detailsTable = nutupane.table;

            $scope.addContentViews = function () {
                var selectedRows = nutupane.getAllSelectedResults().included.resources,
                    versionIds = [];

                angular.forEach(selectedRows, function (contentView) {
                    if (!contentView.versionId) {
                        contentView.versionId = contentView.versions[contentView.versions.length - 1].id;
                    }
                    versionIds.push(contentView.versionId);
                });

                $scope.contentView['component_ids'] = $scope.contentView['component_ids'].concat(versionIds);

                $scope.save($scope.contentView).then(function () {
                    nutupane.refresh();
                });
            };
        }]
);
