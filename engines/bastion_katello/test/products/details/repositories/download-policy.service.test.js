describe('Service: DownloadPolicy', function() {
    var DownloadPolicy;

    beforeEach(module('Bastion.repositories'));

    beforeEach(module(function ($provide) {
        $provide.value('translate', function (string) { return string; });
    }));

    beforeEach(inject(function($injector) {
        DownloadPolicy = $injector.get('DownloadPolicy');
    }));

    it("provides a method to convert a download policy to a human readable version", function() {
        expect(DownloadPolicy.downloadPolicyName('on_demand')).toBe('On Demand');
        expect(DownloadPolicy.downloadPolicyName('immediate')).toBe('Immediate');
        expect(DownloadPolicy.downloadPolicyName('background')).toBe('Background');
    });

});
