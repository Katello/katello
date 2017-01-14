describe('Service: OstreeUpstreamSyncPolicy', function() {
    var OstreeUpstreamSyncPolicy;

    beforeEach(module('Bastion.repositories'));

    beforeEach(module(function ($provide) {
        $provide.value('translate', function (string) { return string; });
    }));

    beforeEach(inject(function($injector) {
        OstreeUpstreamSyncPolicy = $injector.get('OstreeUpstreamSyncPolicy');
    }));

    it("provides a method to convert a OstreeUpstreamSyncPolicy policy to a human readable version", function() {
        expect(OstreeUpstreamSyncPolicy.syncPolicyName('latest')).toBe('Latest Only');
        expect(OstreeUpstreamSyncPolicy.syncPolicyName('all')).toBe('All History');
        expect(OstreeUpstreamSyncPolicy.syncPolicyName('custom', 100)).toBe('Custom Depth (Currently 100)');
    });
});
