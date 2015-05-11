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
    ['$scope', 'translate', 'ContentView', 'Nutupane',
    function ($scope, translate, ContentView, Nutupane) {
        var nutupane;

        nutupane = new Nutupane(ContentView, {
            id: $scope.$stateParams.contentViewId,
            'sort_by': 'created_at',
            'sort_order': 'DESC'
        }, 'history');

        nutupane.table.closeItem = function () {};
        $scope.detailsTable = nutupane.table;

        $scope.actionText = function (history) {
            var message,
                taskType = history.task.label,
                taskTypes = $scope.taskTypes;

            if (taskType === taskTypes.deletion) {
                message = translate("Deleted from %s").replace('%s', history.environment.name);
            } else if (taskType === taskTypes.promotion) {
                message = translate("Promoted to %s").replace('%s', history.environment.name);
            } else if (taskType === taskTypes.publish) {
                message = translate("Published new version");
            }

            return message;
        };
    }]
);
