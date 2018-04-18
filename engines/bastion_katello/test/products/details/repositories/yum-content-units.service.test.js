describe('Service: YumContentUnits', function() {
    var YumContentUnits;

    beforeEach(module('Bastion.repositories'));

    beforeEach(module(function ($provide) {
        $provide.value('translate', function (string) { return string; });
    }));

    beforeEach(inject(function($injector) {
        YumContentUnits = $injector.get('YumContentUnits');
    }));

    it("provides a method to convert a YumContentUnits policy to a human readable version", function() {
        expect(YumContentUnits.unitName('rpm')).toBe('RPM');
        expect(YumContentUnits.unitName('srpm')).toBe('Source RPM');
    });
});
