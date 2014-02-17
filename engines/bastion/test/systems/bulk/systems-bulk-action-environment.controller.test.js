/**
 * Copyright 2013 Red Hat, Inc.
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

describe('Controller: SystemsBulkActionEnvironmentController', function() {
    var $scope, BulkAction, selectedSystems, CurrentOrganization, ContentView, paths, Organization;

    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        BulkAction = {
            environmentContentView: function() {}
        };

        CurrentOrganization = 'foo';
        paths = [[{name: "Library", id: 1}, {name: "Dev", id: 2}]]
        selectedSystems = {included: {ids: [1, 2, 3]}};
        ContentView = $injector.get('MockResource').$new();
        Organization = $injector.get('MockResource').$new();

        Organization.registerableEnvironments = function (params, callback) {
            var response = paths;

            if (callback) {
                callback.apply(this, response);
            }

            return response;
        };
    }));

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();
        $scope.nutupane = {};
        $scope.nutupane.getAllSelectedResults = function () { return selectedSystems }
        $scope.setState = function() {};

        $scope.table = {
            rows: [],
            numSelected: 5
        };

        $controller('SystemsBulkActionEnvironmentController', {$scope: $scope,
            SystemBulkAction: BulkAction,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            ContentView: ContentView
	    });
    }));


    it("Should fetch environments on initial load", function () {
        expect($scope.environments).toBe(paths)
    });

    it("should fetch content views", function () {
        $scope.selected.environment = paths[0][0];
        spyOn(ContentView, 'query').andCallThrough();

        $scope.fetchViews();
        expect(ContentView.query).toHaveBeenCalled();
        expect($scope.contentViews).toBe(ContentView.query().results);
    });

    it("should perform the correct action", function () {
        var params = _.extend(selectedSystems, {environment_id: paths[0][0].id, content_view_id: 109, organization_id: CurrentOrganization});
        $scope.selected.environment = paths[0][0];
        $scope.selected.contentView = {id: 109};
        spyOn(BulkAction, 'environmentContentView')

        $scope.performAction();
        expect(BulkAction.environmentContentView).toHaveBeenCalledWith(params, jasmine.any(Function), jasmine.any(Function));
    });
});
