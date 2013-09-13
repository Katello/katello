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

describe('Controller: ProductDetailsInfoController', function() {
    var $scope;

    beforeEach(module(
        'Bastion.products',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            Product = $injector.get('MockResource').$new(),
            GPGKey = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {productId: 1};

        $controller('ProductDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            Product: Product,
            GPGKey: GPGKey
        });
    }));

    it('provides a method to retrieve available gpg keys', function() {
        var promise = $scope.gpgKeys();

        promise.then(function(gpgKeys) {
            expect(gpgKeys).toEqual($scope.gpgKeys);
        });
    });

    it('should save the product and return a promise', function() {
        var promise = $scope.save($scope.product);

        expect(promise.then).toBeDefined();
    });

    it('should save the product successfully', function() {
        $scope.save($scope.product);

        expect($scope.saveSuccess).toBe(true);
    });

    it('should fail to save the product', function() {
        $scope.product.failed = true;
        $scope.save($scope.product);

        expect($scope.saveSuccess).toBe(false);
        expect($scope.saveError).toBe(true);
    });

});
