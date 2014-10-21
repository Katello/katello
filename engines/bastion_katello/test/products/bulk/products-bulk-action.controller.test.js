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

describe('Controller: ProductsBulkActionController', function() {
    var $scope, $q, translate, ProductBulkAction, CurrentOrganization, selected;

    beforeEach(module('Bastion.products'));

    beforeEach(function() {
        selected = [{id: 1}, {id: 2}, {id: 3}];
        ProductBulkAction = {
            removeProducts: function() {
                var deferred = $q.defer();
                return {$promise: deferred.promise};
            }
        };
        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function($controller, $rootScope, _$q_) {
        $scope = $rootScope.$new();
        $q = _$q_;

        $scope.productTable = {
            getSelected: function () { return selected; }
        };

        $controller('ProductsBulkActionController', {
            $scope: $scope,
            translate: translate,
            ProductBulkAction: ProductBulkAction,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it("can remove multiple products", function() {
        spyOn(ProductBulkAction, 'removeProducts').andCallThrough();

        $scope.removeProducts();

        expect(ProductBulkAction.removeProducts).toHaveBeenCalledWith(_.extend({ids: [1, 2, 3]}, {'organization_id': 'foo'}),
            jasmine.any(Function), jasmine.any(Function));
    });
});
