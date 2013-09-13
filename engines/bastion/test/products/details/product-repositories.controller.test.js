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

describe('Controller: ProductRepositoriesController', function() {
    var $scope;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Repository = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {productId: 1};

        $controller('ProductRepositoriesController', {
            $scope: $scope,
            Repository: Repository,
            CurrentOrganization: 'ACME'
        });
    }));

    it("puts a list of repositories on the scope", function() {
        expect($scope.repositories).toBeDefined();
    });

    it('provides a method to transition to repository details', function() {
        spyOn($scope, 'transitionTo');
        $scope.showRepository($scope.repositories[0]);

        expect($scope.transitionTo).toHaveBeenCalledWith(
            'products.details.repositories.info',
            {
                productId: $scope.$stateParams.productId,
                repositoryId: $scope.repositories[0].id
            }
        );
    });

    it('provides a method to transition to repository creation', function() {
        spyOn($scope, 'transitionTo');
        $scope.openCreateRepository(1);

        expect($scope.transitionTo).toHaveBeenCalledWith(
            'products.details.repositories.new',
            {productId: 1}
        );
    });

});
