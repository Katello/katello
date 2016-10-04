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
            var nutupane, params;

            params = {
                'full_result': true,
                nondefault: true,
                noncomposite: true,
                'organization_id': CurrentOrganization
            };

            nutupane = new Nutupane(ContentView, params);
            nutupane.table.initialLoad = false;
            $scope.detailsTable = nutupane.table;

            $scope.contentView.$promise.then(function (contentView) {
                var filterIds = [];

                if (contentView.components) {
                    filterIds = _.map(contentView.components, 'content_view_id');
                }
                filterIds.push(contentView.id);

                params['without[]'] = filterIds;

                nutupane.setParams(params);
                nutupane.load(true);
            });


            $scope.addContentViews = function () {
                var selectedRows = nutupane.getAllSelectedResults().included.resources,
                    existingComponentsIds = $scope.contentView['component_ids'],
                    versionIds = [];

                angular.forEach(selectedRows, function (contentView) {
                    if (!contentView.versionId) {
                        contentView.versionId = contentView.versions[contentView.versions.length - 1].id;
                    }
                    versionIds.push(contentView.versionId);
                });

                $scope.contentView['component_ids'] = existingComponentsIds.concat(versionIds);

                $scope.save($scope.contentView).then(function () {
                    var newContentIds = _.map(selectedRows, 'id');
                    params['without[]'] = params["without[]"].concat(newContentIds);
                    nutupane.setParams(params);
                    nutupane.refresh();
                }, function () {
                    $scope.contentView['component_ids'] = existingComponentsIds;
                });


            };
        }]
);
