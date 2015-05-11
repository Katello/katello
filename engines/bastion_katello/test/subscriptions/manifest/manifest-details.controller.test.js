describe('Controller: ManifestDetailsController', function() {
    var $scope, organization, $q;

    beforeEach(module(
        'Bastion.subscriptions',
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
            $httpBackend = $injector.get('$httpBackend');

        $httpBackend.expectGET('/api/organization/ACME').respond(organization);

        $scope = $injector.get('$rootScope').$new();
        $q = $injector.get('$q');

        $scope.$stateParams = {subscriptionId: 1};

        $scope.redhatProvider = Organization.redhatProvider();

        $controller('ManifestDetailsController', {
            $scope: $scope,
            $q: $q,
            CurrentOrganization: "ACME",
            Organization: Organization
        });
    }));

    it('should attach the manifest import to the scope', function() {
        $q.all([$scope.organization.$promise]).then(function(prov, org) {
            expect($scope.manifestImport).toBeDefined();
            expect($scope.manifestImport.upstreamId).toBe('abc124');
            expect($scope.manifestImport.generatedBy).toBe('bilbo');
        });
    });

});
