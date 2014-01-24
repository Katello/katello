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
    var $scope, gettext, MenuExpander;

    beforeEach(module(
        'Bastion.products',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            Product = $injector.get('MockResource').$new(),
            SyncPlan = $injector.get('MockResource').$new();
            GPGKey = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {productId: 1};

        MenuExpander = {};

        gettext = function(message) {
            return message;
        };

        $controller('ProductDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            gettext: gettext,
            Product: Product,
            SyncPlan: SyncPlan,
            GPGKey: GPGKey,
            MenuExpander: MenuExpander
        });
    }));

    it("sets the menu expander on the scope", function() {
        expect($scope.menuExpander).toBe(MenuExpander);
    });

    it('provides a method to retrieve available gpg keys', function() {
        var promise = $scope.gpgKeys(),
            promiseCalled = false;

        expect(promise.then).toBeDefined();
        promise.then(function(gpgKeys) {
            expect(gpgKeys).toBeDefined();
            expect(gpgKeys).toContain({id: null});
            promiseCalled = true;
        });

        $scope.$apply();
        expect(promiseCalled).toBe(true);
    });

    it('should save the product and return a promise', function() {
        var promise = $scope.save($scope.product);

        expect(promise.then).toBeDefined();
    });

    it('should save the product successfully', function() {
        $scope.save($scope.product);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.errorMessages.length).toBe(0);
    });

    it('should fail to save the product', function() {
        $scope.product.failed = true;

        $scope.save($scope.product);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });

    it('provides a way to sync a product', function() {
        $scope.product.$sync = function () {};
        spyOn($scope.product, '$sync');

        $scope.syncProduct();

        expect($scope.product.$sync).toHaveBeenCalled();
    });

    it('provides a way to attach a sync plan to the product', function() {

    });

});
