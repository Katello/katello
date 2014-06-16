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
 * @name  Bastion.content-views.controller:ContentViewCompositeContentViewsListController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires ContentView
 *
 * @description
 *  Provides a nutupane for existing content views that are included in the composite.
 */
angular.module('Bastion.content-views').controller('ContentViewCompositeContentViewsListController',
    ['$scope', '$q', 'translate', 'Nutupane', 'CurrentOrganization', 'ContentView',
    function ($scope, $q, translate, Nutupane, CurrentOrganization, ContentView) {
        var nutupane = new Nutupane(ContentView, {
            'organization_id': CurrentOrganization,
            'id': $scope.$stateParams.contentViewId,
            'full_result': true
        }, 'components');

        $scope.detailsTable = nutupane.table;

        $scope.getContentViewForVersion = function (contentViewVersion) {
            var deferred = $q.defer();

            ContentView.get({id: contentViewVersion['content_view_id']}, function (response) {
                deferred.resolve(response.versions);
            });

            return deferred.promise;
        };

        $scope.saveContentViewVersion = function (contentViewVersion) {
            var contentViewVersionToRemove = _.find($scope.contentView.components, function (component) {
                return component['content_view_id'] === contentViewVersion['content_view_id'];
            });

            $scope.contentView['component_ids'] = _.without($scope.contentView['component_ids'], contentViewVersionToRemove.id);
            $scope.contentView['component_ids'].push(contentViewVersion.id);

            $scope.save($scope.contentView).then(function () {
                nutupane.refresh();
            });
        };

        $scope.removeContentViews = function () {
            var selected = nutupane.getAllSelectedResults().included.ids;

            $scope.contentView['component_ids'] = _.difference($scope.contentView['component_ids'], selected);

            $scope.save($scope.contentView).then(function () {
                nutupane.refresh();
            });
        };

        $scope.getVersionString = function (contentViewVersion) {
            return translate('Version %s').replace('%s', contentViewVersion.version.toString());
        };
    }]
);
