/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewCompositeAvailableContentViewsController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires ContentView
 * @requires ContentViewComponent
 *
 * @description
 *  Provides a nutupane for eligible content views to be included in the composite.
 */
angular.module('Bastion.content-views').controller('ContentViewCompositeAvailableContentViewsController',
    ['$scope', 'Nutupane', 'CurrentOrganization', 'ContentView', 'ContentViewComponent',
        function ($scope, Nutupane, CurrentOrganization, ContentView, ContentViewComponent) {
            var nutupane, params, nutupaneParams;

            params = {
                'full_result': true,
                nondefault: true,
                noncomposite: true,
                'organization_id': CurrentOrganization
            };

            nutupaneParams = {
                'disableAutoLoad': true
            };

            nutupane = new Nutupane(ContentView, params, undefined, nutupaneParams);
            $scope.controllerName = 'katello_content_views';
            nutupane.masterOnly = true;
            $scope.table = nutupane.table;

            $scope.contentView.$promise.then(function (contentView) {
                var filterIds = [];
                if (contentView["content_view_components"]) {
                    filterIds = _.map(contentView["content_view_components"], function (component) {
                        return component['content_view'].id;
                    });
                }
                filterIds.push(contentView.id);

                params['without[]'] = filterIds;

                nutupane.setParams(params);
                nutupane.refresh();
            });

            $scope.addContentViews = function () {
                var selectedRows = nutupane.getAllSelectedResults().included.resources,
                    components;
                components = _.map(selectedRows, function (view) {
                    var component = {};
                    if ((!view.versionId) || view.versionId === "latest") {
                        component.latest = true;
                        component["content_view_id"] = view.id;
                    } else {
                        component["content_view_version_id"] = view.versionId;
                    }
                    return component;
                });

                ContentViewComponent.addComponents({compositeContentViewId: $scope.contentView.id,
                                                    components: components}, function () {
                    var newContentIds = _.map(selectedRows, 'id');
                    $scope.saveSuccess();
                    $scope.fetchContentView();
                    params['without[]'] = params["without[]"].concat(newContentIds);
                    nutupane.setParams(params);
                    nutupane.refresh();
                }, $scope.saveError);
            };
        }]
);
