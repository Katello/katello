/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostDebsActionsController
 *
 * @requires $scope
 * @requires translate
 *
 * @description
 *   Provides the functionality for the content host deb package actions.
 */
angular.module('Bastion.content-hosts').controller('ContentHostDebsActionsController',
    ['$scope', 'translate', function ($scope, translate) {
        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Deb Package Actions');

        $scope.packageAction = {actionType: 'packageInstall'};  // default to packageInstall
    }
]);
