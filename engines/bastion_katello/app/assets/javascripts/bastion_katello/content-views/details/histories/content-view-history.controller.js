/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewHistoryController
 *
 * @requires $scope
 * @requires ContentView
 * @requires Nutupane
 *
 * @description
 *   A controller for showing the history of a content view
 */
angular.module('Bastion.content-views').controller('ContentViewHistoryController',
    ['$scope', 'translate', 'ContentViewHistory', 'Nutupane',
    function ($scope, translate, ContentViewHistory, Nutupane) {
        var nutupane;

        nutupane = new Nutupane(ContentViewHistory, {
            contentViewId: $scope.$stateParams.contentViewId,
            'sort_by': 'content_view_version_id',
            'sort_order': 'DESC'
        });
        $scope.controllerName = 'katello_content_views';

        nutupane.table.closeItem = function () {};
        $scope.table = nutupane.table;

        $scope.actionText = function (history) {
            var message,
                taskTypes = $scope.taskTypes,
                taskType = history.task ? history.task.label : taskTypes[history.action];

            if (taskType === taskTypes.deletion) {
                message = translate("Deleted from %s").replace('%s', history.environment.name);
            } else if (taskType === taskTypes.promotion) {
                message = translate("Promoted to %s").replace('%s', history.environment.name);
            } else if (taskType === taskTypes.publish) {
                message = translate("Published new version");
            } else if (taskType === taskTypes.export) {
                message = translate("Exported content view");
            } else if (taskType === taskTypes.incrementalUpdate) {
                message = translate("Incremental update");
            }

            return message;
        };
    }]
);
