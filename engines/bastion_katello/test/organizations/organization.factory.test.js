describe('Factory: Organization', function() {
    var $httpBackend,
        task,
        Organization,
        organizations, flushAfterFunction = true;

    beforeEach(module('Bastion.organizations', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        organizations = {
            records: [
                { name: 'ACME', id: 1},
                { name: 'ECME', id: 2}
            ],
            total: 2,
            subtotal: 2
        };

        task = {id: 'task_id'};
        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Organization = $injector.get('Organization');
    }));

    afterEach(function() {
        if (flushAfterFunction) {
            $httpBackend.flush();
        };

        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way retrieve an organization', function() {
        $httpBackend.expectGET('katello/api/v2/organizations').respond(organizations);
        Organization.queryPaged(function(organizations) {
            expect(organizations.records.length).toBe(2);
        });
    });

    it('provides a way to get repo discover', function() {
        $httpBackend.expectPOST('katello/api/v2/organizations/ACME/repo_discover').respond(task);
        Organization.repoDiscover({ id: 'ACME' , url: '/foo'});
    });

    it('provides a way to cancel repo discover', function() {
        $httpBackend.expectPOST('katello/api/v2/organizations/ACME/repo_discover').respond(task);
        Organization.repoDiscover({ id: 'ACME' , url: '/foo'});
    });

    it('provides a way to get an org', function() {
        $httpBackend.expectGET('katello/api/v2/organizations/ACME').respond(organizations.records[0]);

        Organization.get({ id: 'ACME' }, function(response) {
            expect(response.id).toBe(1);
        });
    });

    it("provides a way to get the organizations's readableEnvironments", function() {
        var pathIndex, envIndex, readableEnvs,
            response = {
                "total": 2,
                "subtotal": 2,
                "results": [
                    {
                        "environments": [
                            {   "id": 1,
                                "name": "Library",
                                "prior": null,
                                "permissions": {
                                    "readable": true,
                                }
                            },
                            {
                                "id": 2,
                                "name": "new-env",
                                "prior": {
                                    "name": "Library",
                                    "id": 1
                                },
                                "permissions": {
                                    "readable": true,
                                }
                            },
                        ]
                    },
                    {
                        "environments": [
                            {
                                "id": 1,
                                "name": "Library",
                                "prior": null,
                                "permissions": {
                                    "readable": true,
                                }
                            },
                            {
                                "id": 5,
                                "name": "new-path",
                                "prior": {
                                    "name": "Library",
                                    "id": 1
                                },
                                "permissions": {
                                    "readable": false,
                                }
                            }
                        ]
                    }
                ]
            };

        //testing the transform
        // from [{environments : [{id, name, permissions: {readable : true}}]}]
        // to [[{id, name, select: true}]]
        $httpBackend.expectGET('katello/api/v2/organizations/ACME/environments/paths').respond(response);
        readableEnvs = Organization.readableEnvironments({"id":"ACME"});
        $httpBackend.flush ();
        flushAfterFunction = false;
        expect(readableEnvs.length).toBe(2);

        for (pathIndex = 0; pathIndex < readableEnvs.length; ++pathIndex) {
            for (envIndex = 0; envIndex < readableEnvs[pathIndex].length; ++envIndex) {
                expect(readableEnvs[pathIndex][envIndex].id).toBe(response[pathIndex].environments[envIndex].id);
                expect(readableEnvs[pathIndex][envIndex].name).toBe(response[pathIndex].environments[envIndex].name);
                expect(readableEnvs[pathIndex][envIndex].select).toBe(response[pathIndex].environments[envIndex].permissions.readable);
            }
        }

    });
});
