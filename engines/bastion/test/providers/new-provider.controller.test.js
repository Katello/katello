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

describe('Controller: NewProviderController', function() {
    var $scope,
        Provider;

    beforeEach(module('Bastion.providers', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        $controller = $injector.get('$controller');
        $scope = $injector.get('$rootScope').$new();
        Provider = $injector.get('MockResource').$new();

        $scope.providerForm = $injector.get('MockForm');
        $scope.product = {};

        $controller('NewProviderController', {
            $scope: $scope,
            Provider: Provider,
            CurrentOrganization: 'ACME'
        });
    }));

    it('should attach a new provider resource onto the scope', function() {
        expect($scope.provider).toBeDefined();
    });

    it('should save a new provider resource', function() {
        var provider = $scope.provider;

        spyOn($scope, 'transitionTo');
        spyOn(provider, '$save').andCallThrough();
        $scope.save(provider);

        expect(provider.$save).toHaveBeenCalled();
        expect($scope.product['provider_id']).toBe($scope.provider.id)
        expect($scope.transitionTo).toHaveBeenCalledWith('products.new.form');
    });

    it('should fail to save a new provider resource', function() {
        var provider = $scope.provider;

        provider.failed = true;
        spyOn(provider, '$save').andCallThrough();
        $scope.save(provider);

        expect(provider.$save).toHaveBeenCalled();
        expect($scope.providerForm['name'].$invalid).toBe(true);
        expect($scope.providerForm['name'].$error.messages).toBeDefined();
    });

});
