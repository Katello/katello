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

describe('Controller: SyncPlanProductsController', function() {
    var $scope,
        $controller,
        gettext,
        SyncPlan,
        Nutupane;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        SyncPlan = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        SyncPlan.removeProducts = function() {};

        gettext = function(message) {
            return message;
        };

        Nutupane = function() {
            this.table = {};
        };

        $controller('SyncPlanProductsController', {
            $scope: $scope,
            $q: $q,
            gettext: gettext,
            SyncPlan: SyncPlan,
            Nutupane: Nutupane
        });

        $scope.syncPlan = new SyncPlan({
            id: 2,
            products: [{id: 1, name: "lalala"}, {id: 2, name: "hello!"}]
        });
    }));

    it('attaches the products nutupane table to the scope', function() {
        expect($scope.productsTable).toBeDefined();
    });

    it("allows removing products groups from the sync plan", function() {
        var expected = {product_ids: [1]};
        spyOn(SyncPlan, 'removeProducts');

        $scope.productsTable.getSelected = function() {
            return [{id: 1, name: "lalala"}];
        };

        $scope.removeProducts();
        expect(SyncPlan.removeProducts).toHaveBeenCalledWith({id: 2}, expected, jasmine.any(Function), jasmine.any(Function));
    });
});
