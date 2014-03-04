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

describe('Service: ContentViewRepositoriesService', function() {
    var $scope;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'gettext'))

    beforeEach(inject(function($injector) {
        var repositoryUtil = $injector.get('ContentViewRepositoriesUtil');

        $scope = $injector.get('$rootScope').$new();
        repositoryUtil($scope);
    }));

    it("should put a product object on the scope", function() {
        expect($scope.product).toBeDefined();
    });

    it("should provide a way to filter repositories by all products", function() {
        var repository = {product: {id: 1}};

        expect($scope.repositoryFilter(repository)).toBe(true);
    });

    it("should provide a way to filter repositories by product", function() {
        var repository = {product: {id: 1}};

        $scope.product = {id: 2};

        expect($scope.repositoryFilter(repository)).toBe(false);
    });

    it("should watch repositoriesTable rows and set the scope products list", function() {
        $scope.repositoriesTable = {rows: []};
        $scope.$digest();

        expect(Object.keys($scope.products).length).toBe(1);

        $scope.repositoriesTable['rows'] = [{product: {id: 1}}];
        $scope.$digest();

        expect(Object.keys($scope.products).length).toBe(2);
    });

});
