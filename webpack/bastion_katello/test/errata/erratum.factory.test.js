describe('Factory: Erratum', function() {
    var Erratum, erratum;

    beforeEach(module('Bastion.errata'));

    beforeEach(module(function($provide) {
        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function(_Erratum_) {
        Erratum = _Erratum_;
    }));

    it("provides a way to update a content host", function() {
        var applicable_systems = [2, 3, 4],
            erratum = {
                id: 1,
                'hosts_applicable': applicable_systems
            };

        $httpBackend.expectGET('api/v2/errata/1').respond(erratum);

        Erratum.applicableContentHosts({id: 1}, function (result) {
            expect(result.results).toEqual(applicable_systems);
            expect(result.subtotal).toBe(3);
            expect(result.total).toBe(3);
        });
    });
});
