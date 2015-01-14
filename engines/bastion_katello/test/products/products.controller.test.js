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

describe('Controller: ProductsController', function() {
    var $scope,
        Nutupane;

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
        expect($scope.productTable).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.productTable.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('products.index');
    });

    it('properly detects most important sync state error', function () {
        var product = {
            'sync_summary': {
                'error': 1,
                'success': 5
            }
        };
        expect($scope.mostImportantSyncState(product)).toBe('error');
    });

    it('properly detects most important sync state pending', function () {
        var product = {
            'sync_summary': {
                'pending': 1,
                'error': 1,
                'success': 5
            }
        };
        expect($scope.mostImportantSyncState(product)).toBe('pending');
    });

    it('properly detects most important sync state success', function () {
        var product = {
            'sync_summary': {
                'success': 5
            }
        };
        expect($scope.mostImportantSyncState(product)).toBe('success');
    });
});

