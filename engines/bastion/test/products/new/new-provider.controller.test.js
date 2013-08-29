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
        $state,
        Provider;

    beforeEach(module('Bastion.products', 'Bastion.providers'));

    beforeEach(inject(function($injector) {
        $scope = $injector.get('$rootScope').$new();
        Provider = $injector.get('Provider');
        $controller = $injector.get('$controller');
        $state = $injector.get('$state');

        CurrentOrganization = 'ACME';
        $scope.providerForm = {};

        $controller('NewProviderController', {
            $scope: $scope,
            Provider: Provider,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it('should attach a new provider resource onto the scope', function() {
        expect($scope.provider).toBeDefined();
    });

    it('should save a new provider resource', function() {
        var provider = $scope.provider;

        spyOn(provider, '$save');
        $scope.save(provider);

        expect(provider.$save).toHaveBeenCalled();
    });

    it('should reset the new provider form', function() {
        var provider = $scope.provider;

        spyOn(provider, '$save');
        $scope.save(provider);

        expect(provider.$save).toHaveBeenCalled();
    });

});

