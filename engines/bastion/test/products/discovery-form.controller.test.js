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

describe('Controller: DiscoveryFormController', function() {
    var $scope,
        Product,
        $httpBackend;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            Provider = $injector.get('MockResource'),
            Repository = $injector.get('MockResource');

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');
        Product = $injector.get('MockResource'),

        $controller('DiscoveryFormController', {
            $scope: $scope,
            $http: $http,
            CurrentOrganization: 'ACME',
            Provider: Provider,
            Product: Product,
            Repository: Repository
        });
    }));

    it('should provide a way to transition to the discovery page', function() {
        spyOn($scope, 'transitionTo');
        $scope.transitionToDiscovery();

        expect($scope.transitionTo).toHaveBeenCalledWith('products.discovery.scan');
    });

    it('should provide a way to determine if a repository is currently being created', function() {
        expect($scope.creating()).toEqual($scope.createRepoChoices.creating);
    });

    it('should attach an object to the scope that defines create choices for a repository', function() {
        expect($scope.createRepoChoices).toBeDefined();
    });

    it('should fetch available providers and put them on the scope', function() {
        expect($scope.providers).toBeDefined();
    });

    it('should set the repository choices product provider id', function() {
        expect($scope.createRepoChoices.product['provider_id']).toBeDefined();
    });

    it('should fetch available products and put them on the scope', function() {
        expect($scope.products).toBeDefined();
    });

    it('should set the repository choices existingProductId', function() {
        expect($scope.createRepoChoices.existingProductId).toBeDefined();
    });

    it('should fetch a label whenever the name changes', function() {
        $httpBackend.expectGET('/katello/organizations/default_label?name=ChangedName').respond('changed_name');

        $scope.createRepoChoices.product.name = 'ChangedName';
        $scope.$apply();
        $httpBackend.flush();

        expect($scope.createRepoChoices.product.label).toBe('changed_name');
    });

    it('should save a product if creating repos on a new product', function() {
        spyOn(Product, 'save');

        $scope.createRepoChoices.newProduct = "true";
        $scope.createRepos()

        expect(Product.save).toHaveBeenCalled();
    });

    it('should transition to repositories page if there are no repositories to be created', function() {
        spyOn($scope, 'transitionTo');

        $scope.createRepos();

        expect($scope.transitionTo).toHaveBeenCalled();
    });

});

