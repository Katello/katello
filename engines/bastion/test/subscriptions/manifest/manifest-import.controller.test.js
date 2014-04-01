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

describe('Controller: ManifestImportController', function() {
    var $scope, provider, organization, history, $q, Task, Organization, Provider;

    beforeEach(module(
        'Bastion.subscriptions',
        'Bastion.providers',
        'Bastion.test-mocks'
    ));

    beforeEach(module(function($provide) {
        provider = {
            name: "Red Hat",
            id: 1
        };

        organization = {
            name: "ACME",
            id: 1,
            owner_details: {
                upstreamConsumer: {
                    uuid: 'borges',
                    name: 'uqbar_tlon',
                    webUrl: 'http://redhat.com'
                }
            }
        };

        history = ["first", "second", "third", "fourth"];

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $httpBackend = $injector.get('$httpBackend'),
            translate;

        Organization = $injector.get('Organization');
        Provider = $injector.get('Provider');

        $httpBackend.expectGET('/api/organization/ACME').respond(organization);
        $httpBackend.expectGET('/api/providers/1').respond(provider);

        $scope = $injector.get('$rootScope').$new();
        $q = $injector.get('$q');
        $scope.$stateParams = {providerId: provider.id};
        $scope.provider = Provider.get({id: provider.id});

        Task = {registerSearch: function() {}};

        // stub out manifestHistory since it's being tested elsewhere
        $scope.manifestHistory = function(prov) { return history; };

        translate = function(a) { return a };

        $controller('ManifestImportController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            CurrentOrganization: "ACME",
            Provider: Provider,
            Organization: Organization,
            Task: Task
        });
    }));

    it('should attach organization to the scope', function() {
        expect($scope.organization).toBeDefined();
    });

    it('should attach provider to the scope', function() {
        expect($scope.provider).toBeDefined();
    });

    it('should provider a method for getting manifest history info', function() {
        $q.all([$scope.provider.$promise, $scope.organization.$promise]).then(function () {
            expect($scope.manifestStatuses.length).toBe(3);
            expect($scope.showHistoryMoreLink).toBe(true);
            expect($scope.upstream).toBe(organization.owner_details.upstreamConsumer);
            expect($scope.manifestLink).toEqual('http://redhat.com/borges');
            expect($scope.manifestName).toEqual('uqbar_tlon');
        });
    });

    it('should provide a method to save a provider', function() {
        var promise;

        $httpBackend.expectPUT('/api/providers/1').respond(provider);
        promise = $scope.save($scope.provider);
        promise.then(function() {
            expect($scope.successMessages.length).toBe(1);
            expect($scope.errorMessages.length).toBe(0);
        });
    });

    it('should provide a method to delete a manifest', function() {
        $httpBackend.expectPOST('/api/providers/1/delete_manifest').respond(provider);
        spyOn($scope.provider, '$deleteManifest').andCallThrough();
        $scope.deleteManifest($scope.provider);
        $q.all([$scope.provider.$promise, $scope.organization.$promise]).then(function () {
            expect($scope.successMessages.length).toBe(1);
            expect($scope.errorMessages.length).toBe(0);
        });
    });

    it('should provide a method to refresh a manifest', function() {
        $httpBackend.expectPOST('/api/providers/1/refresh_manifest').respond(provider);
        spyOn($scope.provider, '$refreshManifest').andCallThrough();
        $scope.refreshManifest($scope.provider);
        $q.all([$scope.provider.$promise, $scope.organization.$promise]).then(function () {
            expect($scope.successMessages.length).toBe(1);
            expect($scope.errorMessages.length).toBe(0);
        });
    });

    it('should set an error message if a manifest upload status is not success', function() {
        $q.all([$scope.provider.$promise, $scope.organization.$promise]).then(function () {
            $scope.uploadManifest('<pre>"There was an error"</pre>', true);

            expect($scope.successMessages.length).toBe(0);
            expect($scope.uploadErrorMessages.length).toBe(1);
        });
    });

    it('should set the upload status to success and refresh data if upload status is success', function() {
        $q.all([$scope.provider.$promise, $scope.organization.$promise]).then(function () {
            spyOn($scope, 'refreshTable');
            $scope.uploadManifest('<pre>{"status": "success"}</pre>', true);

            expect($scope.saveSuccess).toBe(true);
            expect($scope.uploadErrorMessages.length).toBe(0);
            expect($scope.successMessages.length).toBe(1);
            expect($scope.refreshTable).toHaveBeenCalled();
        });
    });

    it('should refresh provider info when requested', function() {
        spyOn(Provider, 'get').andCallThrough();
        spyOn(Organization, 'get').andCallThrough();
        $scope.refreshProviderInfo();
        expect(Provider.get).toHaveBeenCalled();
        expect(Organization.get).toHaveBeenCalled();
    })

});
