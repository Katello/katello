describe('Filter:errataType', function() {
    var filter;

    beforeEach(module('Bastion.errata'));

    beforeEach(module(function($provide) {
        $provide.value('translate',  function(a) {return a});
    }));

    beforeEach(inject(function($filter) {
        filter = $filter('errataType');
    }));

    it("returns 'Bug Fix Advisory' if bugfix.", function() {
        expect(filter('bugfix')).toBe('Bug Fix Advisory');
    });

    it("returns 'Product Enhancement Advisory' if enhancement.", function() {
        expect(filter('enhancement')).toBe('Product Enhancement Advisory');
    });

    it("returns 'Secuirty Advisory' if security.", function() {
        expect(filter('security')).toBe('Security Advisory');
    });

    it("returns provided type if not found.", function() {
        expect(filter('blah')).toBe('blah');
    });
});
