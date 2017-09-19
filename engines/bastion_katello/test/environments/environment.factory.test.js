describe('Factory: Environment', function() {
    var environments;

    beforeEach(module('Bastion.environments', 'Bastion.utils'));

    beforeEach(module(function($provide) {
        environments = {
            results: [
                { name: 'Environment1', id: 1 },
                { name: 'Environment2', id: 2 }
            ],
            total: 10,
            subtotal: 5,
            limit: 5,
            offset: 0
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function(_Environment_) {
        Environment = _Environment_;
    }));

    it('provides a way to get a collection of environments', function() {
        $httpBackend.expectGET('katello/api/environments').respond(environments.results);

        Environment.query(function (environments) {
            expect(environments.results.length).toBe(2);
            expect(environments.total).toBe(10);
            expect(environments.subtotal).toBe(5);
            expect(environments.offset).toBe(0);
        });
    });

    it('provides a way to get a single environment', function() {
        $httpBackend.expectGET('katello/api/environments').respond(environments.results[0]);

        Environment.get({ id: 1 }, function (environment) {
            expect(environment).toBeDefined();
            expect(environment.name).toEqual('Environment1');
        });
    });

    it('provides a way to update an environment', function() {
        var environment = environments.results[0];
        environment.name = 'NewEnvName';
        $httpBackend.expectPUT('katello/api/environments').respond(environment);

        Environment.update({ id: 1, name: 'NewEnvName' }, function (environment) {
            expect(environment).toBeDefined();
            expect(environment.name).toEqual('NewEnvName');
        });
    });
});

