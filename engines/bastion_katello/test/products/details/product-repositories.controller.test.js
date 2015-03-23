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

describe('Controller: ProductRepositoriesController', function() {
    var $scope, $q, expectedTable, expectedIds, Repository, RepositoryBulkAction, Nutupane;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            rows = [{id: 1, name: 'blah'}, {id: 2, name: 'blah2'}];

        expectedTable = {
            rows: rows,
            showColumns: function() {},
            getSelected: function() {
                return [rows[1]];
            },
            selectAll: function() {},
            allSelected: false
        };

        expectedIds = _.pluck(rows, 'id');

        Nutupane = function() {
            this.table = expectedTable;
            this.removeRow = function() {};
            this.get = function() {};
            this.query = function() {};
            this.refresh = function() {};
            this.getAllSelectedResults = function() {
                return {
                    included: { ids: expectedIds }
                };
            };
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {productId: 1};

        Repository = $injector.get('MockResource').$new();

        RepositoryBulkAction = $injector.get('MockResource').$new();
        RepositoryBulkAction.syncRepositories = function(params, success, error) {
            return {'$promise': $q.defer().promise};
        };
        RepositoryBulkAction.removeRepositories = function(params, success, error) {
            return {'$promise': $q.defer().promise};
        };

        $controller('ProductRepositoriesController', {
            $scope: $scope,
            Repository: Repository,
            RepositoryBulkAction: RepositoryBulkAction,
            CurrentOrganization: 'ACME',
            Nutupane: Nutupane
        });
    }));

    it("sets up the repositories nutupane table", function() {
        expect($scope.repositoriesTable).toBe(expectedTable);
    });

    it("provides a way to remove all of the selected repositories in the table", function() {
        spyOn(RepositoryBulkAction, 'removeRepositories').andCallThrough();

        $scope.removeSelectedRepositories();
        expect(RepositoryBulkAction.removeRepositories).toHaveBeenCalledWith({ids: expectedIds},
            jasmine.any(Function), jasmine.any(Function));
    });

    it("provides a way to sync all of the selected repositories in the table", function() {
        var errorFunction = jasmine.any(Function);

        spyOn(RepositoryBulkAction, 'syncRepositories').andCallThrough();

        $scope.syncSelectedRepositories();
        expect(RepositoryBulkAction.syncRepositories).toHaveBeenCalledWith({ids: expectedIds},
            jasmine.any(Function), errorFunction);
    });


    it("should provide a valid reason for a repo deletion disablement", function() {
        var product = {id: 100, $resolved: true};

        $scope.denied = function (perm, prod) {
            expect(perm).toBe("delete_products");
            return true;
        };
        expect($scope.getRepositoriesNonDeletableReason(product)).toBe("permissions");
        expect($scope.canRemoveRepositories(product)).toBe(false);

        $scope.denied = function (perm, prod) {
            return false;
        };

        product.redhat = true;
        expect($scope.getRepositoriesNonDeletableReason(product)).toBe("redhat");
        expect($scope.canRemoveRepositories(product)).toBe(false);

        product.redhat = false;
        expect($scope.getRepositoriesNonDeletableReason(product)).toBe(null);
        expect($scope.canRemoveRepositories(product)).toBe(true);
    });

});
