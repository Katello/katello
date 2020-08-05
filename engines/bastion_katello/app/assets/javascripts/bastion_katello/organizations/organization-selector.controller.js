(function () {
    'use strict';

    /**
    * @ngdoc controller
    * @name Bastion.organizations.controller:OrganizationSelectorController
    *
    * @description
    *     Selecting an organization
    */
    function OrganizationSelectorController($scope, Organization, CurrentOrganization, $window) {
        $scope.selectedOrganization = {};

        // TODO: per_page hack necessary because of http://projects.theforeman.org/issues/21800
        Organization.queryUnpaged({'per_page': 99999999999}, function (response) {
            $scope.organizations = response.results;
        });

        $scope.changeOrgAction = function() {
            $window.location.href = $scope.$stateParams.toState;
        };

        $scope.selectOrganization = function (organization) {
            var label = organization.id + '-' + organization.name.replace("'", '').replace(".", '');
            Organization.select({label: label}).$promise.then($scope.changeOrgAction, $scope.changeOrgAction);
        };
    }

    angular
        .module('Bastion.organizations')
        .controller('OrganizationSelectorController', OrganizationSelectorController);

    OrganizationSelectorController.$inject = ['$scope', 'Organization', 'CurrentOrganization', '$window'];
})();
