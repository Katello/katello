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

describe('Controller: ProductFormController', function() {
    var $scope,
        FormUtils,
        $httpBackend;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            $q = $injector.get('$q'),
            Product = $injector.get('MockResource').$new(),
            Provider = $injector.get('MockResource').$new(),
            GPGKey = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');
        FormUtils = $injector.get('FormUtils');

        $scope.productForm = $injector.get('MockForm');
        $scope.productTable = {
            addRow: function() {},
            closeItem: function() {}
        };

        $scope.panel = {};

        $controller('ProductFormController', {
            $scope: $scope,
            $http: $http,
            $q: $q,
            Product: Product,
            Provider: Provider,
            GPGKey: GPGKey,
            FormUtils: FormUtils
        });
    }));

    it('should attach a new product resource on to the scope', function() {
        expect($scope.product).toBeDefined();
    });

    it('should save a new product resource', function() {
        var product = $scope.product;

        spyOn($scope.productTable, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(product, '$save').andCallThrough();
        $scope.save(product);

        expect(product.$save).toHaveBeenCalled();
        expect($scope.productTable.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('products.details.repositories.index',
                                                         {productId: $scope.product.id})
    });

    it('should fail to save a new product resource', function() {
        var product = $scope.product;

        product.failed = true;
        spyOn(product, '$save').andCallThrough();
        $scope.save(product);

        expect(product.$save).toHaveBeenCalled();
        expect($scope.productForm['name'].$invalid).toBe(true);
        expect($scope.productForm['name'].$error.messages).toBeDefined();
    });

    it('should fetch a label whenever the name changes', function() {
        spyOn(FormUtils, 'labelize');

        $scope.product.name = 'ChangedName';
        $scope.$apply();

        expect(FormUtils.labelize).toHaveBeenCalled();
    });

});

