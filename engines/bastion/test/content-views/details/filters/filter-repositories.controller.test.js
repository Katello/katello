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

describe('Controller: FilterRepositoriesController', function() {
    var $scope, $controller, dependencies, Filter, filter;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'gettext'));

    beforeEach(inject(function($injector) {
        var gettext = $injector.get('gettextMock'),
            ContentViewRepositoriesUtil = $injector.get('ContentViewRepositoriesUtil');

        $controller = $injector.get('$controller');
        $scope = $injector.get('$rootScope').$new();
        Filter = $injector.get('MockResource').$new();

        filter = {
            'content_view': {
                repositories: []
            }
        };

        $scope.$stateParams = {
            contentViewId: 10,
            filterId: 3
        };

        $scope.filter = Filter.get({id: 1});
        $scope.filter.repositories = [];
        $scope.filter['content_view'] = filter['content_view'];

        dependencies = {
            $scope: $scope,
            gettext: gettext,
            Filter: Filter,
            ContentViewRepositoriesUtil: ContentViewRepositoriesUtil
        };

        $controller('FilterRepositoriesController', dependencies);

    }));

    it("puts a table object on the $scope", function() {
        expect($scope.repositoriesTable).toBeDefined();
    });

    it("puts the filter on the $scope", function() {
        expect($scope.filter).toBeDefined();
    });

    it("defaults to not showing the repos table", function() {
        expect($scope.showRepos).toBe(false);
    });

    describe("sets the repository table's selected rows", function() {
        it("to the content view's repositories if the filter doesn't have repositories", function() {
            filter['content_view'].repositories = [{id: 1}, {id: 2}];
            $scope.filter.repositories = [];

            $controller('FilterRepositoriesController', dependencies);

            expect($scope.repositoriesTable.rows[0].id).toBe(1);
            expect($scope.repositoriesTable.rows[0].selected).toBe(true);
            expect($scope.repositoriesTable.rows[1].id).toBe(2);
            expect($scope.repositoriesTable.rows[1].selected).toBe(true);
        });

        it("to the filter's repositories if the filter has repositories", function() {
            filter['content_view'].repositories = [{id: 1}, {id: 2}];
            $scope.filter.repositories = [{id: 1}];

            $controller('FilterRepositoriesController', dependencies);

            expect($scope.repositoriesTable.rows[0].id).toBe(1);
            expect($scope.repositoriesTable.rows[0].selected).toBe(true);
            expect($scope.repositoriesTable.rows[1].id).toBe(2);
            expect($scope.repositoriesTable.rows[1].selected).toBe(false);
        });
    });

    it("determines whether or not to show the repos table", function() {
        $scope.filter.repositories = [];

        $controller('FilterRepositoriesController', dependencies);
        expect($scope.showRepos).toBe(false);

        $scope.filter.repositories = [{id: 1}];
        $controller('FilterRepositoriesController', dependencies);
        expect($scope.showRepos).toBe(true);
    });

    it("provides a way to update the selected repositories", function() {
        $scope.repositoriesTable.getSelected = function () {};
        spyOn($scope.repositoriesTable, 'getSelected').andReturn([{id: 1}, {id: 2}]);
        spyOn(Filter, 'update');

        $scope.filter.id = 2;
        $scope.updateRepositories();

        expect(Filter.update).toHaveBeenCalledWith({id: $scope.filter.id, 'repository_ids': [1, 2]},
            jasmine.any(Function), jasmine.any(Function));
    });

    it("provides a way to select all repositories", function() {
        spyOn(Filter, 'update');

        $scope.filter.id = 2;
        $scope.selectAllRepositories();

        expect(Filter.update).toHaveBeenCalledWith({id: $scope.filter.id, 'repository_ids': []},
            jasmine.any(Function), jasmine.any(Function));
    });
});
