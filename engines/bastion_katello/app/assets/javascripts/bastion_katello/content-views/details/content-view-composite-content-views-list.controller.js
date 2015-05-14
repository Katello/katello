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
