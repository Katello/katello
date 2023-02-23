(function () {

    /**
     * @ngdoc object
     * @name  Bastion.debs.controller:DebController
     *
     * @requires Host
     * @requires CurrentOrganization
     * @requires newHostDetailsUI
     *
     * @description
     *   Provides the functionality for the debs details action pane.
     */
    function DebController($scope, Deb, Host, CurrentOrganization, ApiErrorHandler, newHostDetailsUI) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.deb) {
            $scope.panel.loading = false;
        }

        $scope.installedPackageCount = undefined;
        $scope.newHostDetailsUI = (newHostDetailsUI === 'true');

        $scope.fetchHostCount = function() {
            Host.get({'per_page': 0, 'search': $scope.createRawSearchString('installed_deb'), 'organization_id': CurrentOrganization}, function (data) {
                $scope.installedDebCount = data.subtotal;
            });
        };

        $scope.createSearchString = function(field) {
            return encodeURIComponent($scope.createRawSearchString(field));
        };

        $scope.createRawSearchString = function(field) {
            return field + '="' + $scope.deb.name + ':' + $scope.deb.architecture + '=' + $scope.deb.version + '"';
        };

        $scope.deb = Deb.get({id: $scope.$stateParams.debId}, function () {
            $scope.panel.loading = false;
            $scope.fetchHostCount();
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });
    }

    angular
        .module('Bastion.debs')
        .controller('DebController', DebController);

    DebController.$inject = ['$scope', 'Deb', 'Host', 'CurrentOrganization', 'ApiErrorHandler', 'newHostDetailsUI'];

})();
