describe('Service: Checksum', function() {
    var Checksum;

    beforeEach(module('Bastion.repositories'));

    beforeEach(module(function ($provide) {
        $provide.value('translate', function (string) { return string; });
    }));

    beforeEach(inject(function($injector) {
        Checksum = $injector.get('Checksum');
    }));

    it("provides a method to convert a checksum to human readable version", function() {
        expect(Checksum.checksumType(null)).toBe('Default');
        expect(Checksum.checksumType('sha256')).toBe('sha256');
        expect(Checksum.checksumType('sha1')).toBe('sha1');
    });

});