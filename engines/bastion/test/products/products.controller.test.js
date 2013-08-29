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
        $state,
        Nutupane,
        Routes;

    beforeEach(module('Bastion.products'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
        Product = {};
    });

    beforeEach(inject(function($controller, $rootScope, _$state_) {
        $scope = $rootScope.$new();

        $state = _$state_;
        spyOn($state, 'transitionTo');

        $controller('ProductsController', {
            $scope: $scope,
            $state: $state,
            Nutupane: Nutupane,
            Product: Product,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('provides a method to transition states', function() {
        $scope.transitionTo('products.index');

        expect($state.transitionTo).toHaveBeenCalledWith('products.index');
    });

    it('sets the closeItem function to transition to the index page', function() {
        $scope.table.closeItem();

        expect($state.transitionTo).toHaveBeenCalledWith('products.index');
    });

    it('sets the openDetails function to transition to a details page', function() {
        $scope.table.openDetails({ id: 1 });

        expect($state.transitionTo).toHaveBeenCalledWith('products.details.info', { productId: 1 });
    });
});

