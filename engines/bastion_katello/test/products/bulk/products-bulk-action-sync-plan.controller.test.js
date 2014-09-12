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

describe('Controller: ProductsBulkActionSyncPlanController', function() {
    var $scope, $q, ProductBulkAction, SyncPlan, Nutupane, selected;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(function() {
        selected = [1, 2, 3];
        ProductBulkAction = {
            updateProductSyncPlan: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            }
        };

        Nutupane = function () {
            this.table = {};
        };
    });

    beforeEach(inject(function($controller, $rootScope, _$q_, MockResource) {
        $scope = $rootScope.$new();
        $q = _$q_;

        $scope.actionParams = {};
        $scope.getSelectedProductIds = function () { return selected; };
        SyncPlan = MockResource.$new();

        $controller('ProductsBulkActionSyncPlanController', {
            $scope: $scope,
            Nutpane: Nutupane,
            SyncPlan: SyncPlan,
            ProductBulkAction: ProductBulkAction
        });
    }));

    it("creates a nutupane sync plan table", function() {
        expect($scope.syncPlanTable).toBeDefined();
    });

    it("allows the updating of the sync plan", function() {
        spyOn(ProductBulkAction, 'updateProductSyncPlan').andCallThrough();

        $scope.syncPlanTable = {chosenRow: {id: 10}};
        $scope.updateSyncPlan();

        expect(ProductBulkAction.updateProductSyncPlan).toHaveBeenCalledWith({ids: [1, 2, 3], 'plan_id': 10},
            jasmine.any(Function), jasmine.any(Function));
    });

    it("allows the removal of the sync plan", function() {
        spyOn(ProductBulkAction, 'updateProductSyncPlan').andCallThrough();

        $scope.removeSyncPlan();

        expect(ProductBulkAction.updateProductSyncPlan).toHaveBeenCalledWith({ids: [1, 2, 3], 'plan_id': null},
            jasmine.any(Function), jasmine.any(Function));
    });

});
