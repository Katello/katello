describe('Service: MirroringPolicy', function() {
    var MirroringPolicy;

    beforeEach(module('Bastion.repositories'));

    beforeEach(module(function ($provide) {
        $provide.value('translate', function (string) { return string; });
    }));

    beforeEach(inject(function($injector) {
        MirroringPolicy = $injector.get('MirroringPolicy');
    }));

    it("provides a method to convert a download policy to a human readable version", function() {
        expect(MirroringPolicy.mirroringPolicyName('additive', 'yum')).toBe('Additive');
        expect(MirroringPolicy.mirroringPolicyName('mirror_complete', 'yum')).toBe('Complete Mirroring');
    });

    it("returns appropriate policies for repo type", function() {
        expect(Object.keys(MirroringPolicy.mirroringPolicies('yum'))).toContain('mirror_complete');
        expect(Object.keys(MirroringPolicy.mirroringPolicies('file'))).not.toContain('mirror_complete');
    });

});
