/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

describe('Controller: ErrataController', function() {
    var $scope,
        $location,
        $controller,
        dependencies,
        Errata,
        Repository,
        Nutupane;

    beforeEach(module('Bastion.errata', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                params: {},
                showColumns: function() {}
            };
            this.get = function() {};
            this.setParams = function (params) {};
            this.getParams = function (params) { return {}; };
            this.refresh = function () {};
        };
        Errata = {};
    });

    beforeEach(inject(function(_$controller_, $rootScope, _$location_, MockResource, translateMock) {
        Repository = MockResource.$new();
        $scope = $rootScope.$new();
        $location = _$location_;

        $controller = _$controller_;
        dependencies = {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            Errata: Errata,
            Repository: Repository,
            CurrentOrganization: 'CurrentOrganization',
            translate: translateMock
        };

        $controller('ErrataController', dependencies);
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.table.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('errata.index');
    });

    it('gets a list of yum repositories for the organization', function () {
        expect($scope.repositories[0]).toBe($scope.repository);
        expect($scope.repositories.length).toBe(2);
    });

    it('should have a list of repositories that include an all option', function () {
        expect($scope.repositories[0]['id']).toBe('all');
    });

    it("allows the filtering of applicable errata only", function () {
        $scope.showApplicable = true;
        $scope.toggleApplicable();
        expect($scope.table.params['errata_restrict_applicable']).toBe(true)
    });

    it("allows the filtering of installable errata only", function () {
        $scope.showInstallable = false;
        $scope.toggleInstallable();
        expect($scope.table.params['errata_restrict_installable']).toBe(false)
    });

    it('should set the repository_id param on Nutupane when a repository is chosen', function () {
        spyOn($scope.nutupane, 'setParams');
        spyOn($scope.nutupane, 'refresh');

        $scope.repository = {id: 1};
        $scope.$apply();

        expect($scope.nutupane.setParams).toHaveBeenCalledWith({'repository_id': 1});
        expect($scope.nutupane.refresh).toHaveBeenCalled();
    });

    it('allows the setting of the repositoryId via a query string parameter', function () {
        $location.search('repositoryId', '1');

        $controller('ErrataController', dependencies);

        expect($scope.repository.id).toBe(1);
    });
});
