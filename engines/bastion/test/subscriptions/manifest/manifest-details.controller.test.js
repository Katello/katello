/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

describe('Controller: ManifestDetailsController', function() {
    var $scope, provider, organization, $q;

    beforeEach(module(
        'Bastion.subscriptions',
        'Bastion.providers',
        'Bastion.test-mocks'
    ));

    beforeEach(module(function($provide) {
        provider = {
            name: "Red Hat",
            id: 1,
            owner_imports: [
                {
                    upstreamId: 'abc123',
                    generatedBy: 'bilbo',
                    generatedDate: '2014-01-01'
                },
                {
                    upstreamId: 'def234',
                    generatedBy: 'frodo',
                    generatedDate: '2014-02-01'
                }
            ]
        };

        organization = {
            name: "ACME",
            id: 1,
            owner_details: {
                upstreamConsumer: {
                    uuid: 'abc123'
                }
            }
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Organization = $injector.get('Organization'),
            Provider = $injector.get('Provider'),
            $httpBackend = $injector.get('$httpBackend');

        $httpBackend.expectGET('/api/organization/ACME').respond(organization);
        $httpBackend.expectGET('/api/providers/1').respond(provider);

        $scope = $injector.get('$rootScope').$new();
        $q = $injector.get('$q');

        $scope.$stateParams = {subscriptionId: 1};

        $scope.provider = Provider.get({id: provider.id});

        $controller('ManifestDetailsController', {
            $scope: $scope,
            $q: $q,
            CurrentOrganization: "ACME",
            Organization: Organization
        });
    }));

    it('should attach the manifest import to the scope', function() {
        $q.all([$scope.provider.$promise, $scope.organization.$promise]).then(function(prov, org) {
            expect($scope.manifestImport).toBeDefined();
            expect($scope.manifestImport.upstreamId).toBe('abc124');
            expect($scope.manifestImport.generatedBy).toBe('bilbo');
        });
    });

});
