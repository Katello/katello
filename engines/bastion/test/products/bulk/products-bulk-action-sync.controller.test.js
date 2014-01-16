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

describe('Controller: ProductsBulkActionSyncController', function() {
    var $scope, $q, gettext, ProductBulkAction, selected;

    beforeEach(module('Bastion.products'));

    beforeEach(function() {
        selected = [1, 2, 3];
        ProductBulkAction = {
            syncProducts: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            }
        };
        gettext = function() {};
    });
    
    beforeEach(inject(function($controller, $rootScope, _$q_) {
        $scope = $rootScope.$new();
        $q = _$q_;

        $scope.actionParams = {};
        $scope.getSelectedProductIds = function () { return selected; };
        
        $controller('ProductsBulkActionSyncController', {
            $scope: $scope,
            ProductBulkAction: ProductBulkAction,
            gettext: gettext
        });
    }));

    it("can sync products", function() {
        spyOn(ProductBulkAction, 'syncProducts').andCallThrough();
        $scope.syncProducts();

        expect(ProductBulkAction.syncProducts).toHaveBeenCalledWith({ids: [1, 2, 3]}, jasmine.any(Function),
            jasmine.any(Function));
    });

});
