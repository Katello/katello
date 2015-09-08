(function () {

    /**
     * @ngdoc object
     * @name  Bastion.puppet-modules.controller:PuppetModulesDetailsController
     *
     * @description
     *   Provides the functionality for the puppet modules details action pane.
     */
    function PuppetModulesDetailsController($scope, PuppetModule) {
        if ($scope.puppetModule) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.puppetModule = PuppetModule.get({id: $scope.$stateParams.puppetModuleId}, function () {
            $scope.panel.loading = false;
        });
    }

    angular
        .module('Bastion.puppet-modules')
        .controller('PuppetModulesDetailsController', PuppetModulesDetailsController);

    PuppetModulesDetailsController.$inject = ['$scope', 'PuppetModule'];

})();
