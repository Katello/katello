describe('Service: OSVersions', function() {
    var OSVersions;

    beforeEach(module('Bastion.repositories'));

    beforeEach(module(function ($provide) {
        $provide.value('translate', function (string) { return string; });
    }));

    beforeEach(inject(function($injector) {
        OSVersions = $injector.get('OSVersions');
    }));

    it("provides a method to get initial options", function() {
        var result = OSVersions.getOSVersionsOptions();
        var sample = result[0];
        expect(Array.isArray(result)).toBe(true);
        expect(Object.keys(sample)).toEqual(['name', 'id']);
    });

    it("constructs the param from a string", function() {
        var result = OSVersions.osVersionsParam('rhel-7');
        expect(result).toEqual(['rhel-7']);
    });

    it("constructs the param from an object", function() {
        var result = OSVersions.osVersionsParam({
          name: 'Red Hat Enterprise Linux 7',
          id: 'rhel-7'
        });
        expect(result).toEqual(['rhel-7']);
    });

    it("formats OS versions as a string", function() {
        var result = OSVersions.formatOSVersions(['rhel-7', 'rhel-7-server']);
        expect(result).toEqual('rhel-7,rhel-7-server');
    });

});
