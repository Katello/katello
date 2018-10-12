describe('Filter:errataSeverity', function() {
    var filter;

    beforeEach(module('Bastion.errata'));

    beforeEach(module(function($provide) {
        $provide.value('translate',  function(a) {return a});
    }));

    beforeEach(inject(function($filter) {
        filter = $filter('errataSeverity');
    }));

    it("returns 'Moderate' if moderate.", function() {
        expect(filter('Moderate')).toBe('Moderate');
    });

    it("returns 'Important' if important.", function() {
        expect(filter('Important')).toBe('Important');
    });

    it("returns 'Critical' if critical.", function() {
        expect(filter('Critical')).toBe('Critical');
    });

    it("returns 'N/A' if ''.", function() {
        expect(filter('')).toBe('N/A');
    });

    it("returns provided type if not found.", function() {
        expect(filter('blah')).toBe('blah');
    });
});
