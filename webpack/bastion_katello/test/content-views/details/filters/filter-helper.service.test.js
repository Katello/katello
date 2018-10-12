describe('Service: FilterHelper', function() {
    var FilterHelper;

    beforeEach(module('Bastion.content-views'));

    beforeEach(module(function ($provide) {
        $provide.value('translate', function (string) { return string; });
    }));

    beforeEach(inject(function($injector) {
        FilterHelper = $injector.get('FilterHelper');
    }));

    it("provides a method to convert a server side filter content type to a human readable version", function() {
        expect(FilterHelper.contentType('rpm')).toBe('RPM');
        expect(FilterHelper.contentType('erratum')).toBe('Errata');
        expect(FilterHelper.contentType('package_group')).toBe('Package Groups');
        expect(FilterHelper.contentType('docker')).toBe('Container Image Tags');
    });

});
