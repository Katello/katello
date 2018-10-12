/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewCompositeContentViewsListController
 *
 * @requires $scope
 * @requires translate
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires ContentView
 * @requires ContentViewComponent
 *
 * @description
 *  Provides a nutupane for existing content views that are included in the composite.
 */
angular.module('Bastion.content-views').controller('ContentViewCompositeContentViewsListController',
    ['$scope', 'translate', 'Nutupane', 'CurrentOrganization', 'ContentView', 'ContentViewComponent',
    function ($scope, translate, Nutupane, CurrentOrganization, ContentView, ContentViewComponent) {
        var nutupane = new Nutupane(ContentView, {
            'organization_id': CurrentOrganization,
            'id': $scope.$stateParams.contentViewId,
            'full_result': true
        }, 'contentViewComponents');
        $scope.controllerName = 'katello_content_views';

        nutupane.masterOnly = true;
        $scope.table = nutupane.table;

        $scope.saveContentViewComponent = function (contentViewComponent) {
            var component = {
                id: contentViewComponent.id,
                latest: contentViewComponent.versionId === "latest",
                compositeContentViewId: $scope.contentView.id
            };

            if (contentViewComponent.versionId !== "latest") {
                component["content_view_version_id"] = contentViewComponent.versionId;
            }
            ContentViewComponent.update(component, function () {
                nutupane.refresh();
                $scope.saveSuccess();
            }, $scope.saveError);
        };

        $scope.removeContentViewComponents = function () {
            var selected = nutupane.getAllSelectedResults().included.ids,
                params = {compositeContentViewId: $scope.contentView.id,
                          'component_ids': selected};
            ContentViewComponent.removeComponents(params, function () {
                nutupane.refresh();
                $scope.contentView.$get($scope.saveSuccess, $scope.saveError);
            }, $scope.saveError);
        };

        $scope.getVersionString = function (contentViewComponent) {
            if (contentViewComponent.latest) {
                return translate('Latest (Currently %s)').replace('%s', contentViewComponent['content_view_version'].version.toString());
            }
            return contentViewComponent['content_view_version'].version.toString();
        };

        $scope.getVersionId = function (contentViewComponent) {
            if (contentViewComponent.latest) {
                return "latest";
            }
            return contentViewComponent.content_view_version.id;
        };
    }]
);
