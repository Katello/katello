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

describe('Controller: ProductsController', function() {
    var $scope,
        Nutupane,
        Routes;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
        Product = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();

        $controller('ProductsController', {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            Product: Product,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.table.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('products.index');
    });

    it('provides a method to transition to the new product page', function() {
        spyOn($scope, "transitionTo");
        $scope.transitionToNewProduct();

        expect($scope.transitionTo).toHaveBeenCalledWith('products.new.form');
    });

    it('provides a method to transition to the repo discovery page', function() {
        spyOn($scope, "transitionTo");
        $scope.transitionToDiscovery();

        expect($scope.transitionTo).toHaveBeenCalledWith('products.discovery.scan');
    });

    it('sets the openProduct function to transition to a repository page', function() {
        spyOn($scope, "transitionTo");
        $scope.table.openProduct({ id: 1 });

        expect($scope.transitionTo).toHaveBeenCalledWith('products.details.repositories.index', { productId: 1 });
    });

});

