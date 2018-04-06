/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErratumController
 *
 * @requires $scope
 * @requires Errata
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the errata pages.
 */
angular.module('Bastion.errata').controller('ErratumController', ['$scope', 'Erratum', 'ApiErrorHandler',
    function ($scope, Erratum, ApiErrorHandler) {
        $scope.encodeURIComponent = encodeURIComponent;

        $scope.panel = {
            error: false,
            loading: true
        };

        $scope.moduleStreamShowMap = {};

        if ($scope.errata) {
            $scope.panel.loading = false;
        }

        $scope.errata = Erratum.get({id: $scope.$stateParams.errataId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.showModuleStreamList = function (moduleStreamId) {
            return (!$scope.moduleStreamShowMap.hasOwnProperty(moduleStreamId) ||
                     $scope.moduleStreamShowMap[moduleStreamId]);
        };

        $scope.toggleModuleStreamList = function (moduleStreamId) {
            if ($scope.moduleStreamShowMap.hasOwnProperty(moduleStreamId)) {
                $scope.moduleStreamShowMap[moduleStreamId] = !$scope.moduleStreamShowMap[moduleStreamId];
            } else {
                $scope.moduleStreamShowMap[moduleStreamId] = false;
            }
        };

        $scope.moduleStreamChevron = function (moduleStreamId) {
            return $scope.showModuleStreamList(moduleStreamId) ? 'down' : 'right';
        };
    }
]);
