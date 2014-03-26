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

describe('Controller: SyncPlanAddProductsController', function() {
    var $scope,
        $controller,
        translate,
        SyncPlan,
        Nutupane;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        SyncPlan = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        SyncPlan.addProducts = function() {};

        translate = function(message) {
            return message;
        };

        Nutupane = function() {
            this.table = {};
        };

        $controller('SyncPlanAddProductsController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            SyncPlan: SyncPlan,
            Nutupane: Nutupane
        });

        $scope.syncPlan = new SyncPlan({
            id: 2,
            products: [{id: 1, name: "lalala"}]
        });
    }));

    it('attaches the products nutupane table to the scope', function() {
        expect($scope.productsTable).toBeDefined();
    });

    it("allows adding products groups to the sync plan", function() {
        var expected = {product_ids: [2]};
        spyOn(SyncPlan, 'addProducts');

        $scope.productsTable.getSelected = function() {
            return [{id: 2, name: "hello!"}];
        };

        $scope.addProducts();
        expect(SyncPlan.addProducts).toHaveBeenCalledWith({id: 2}, expected, jasmine.any(Function), jasmine.any(Function));
    });
});
