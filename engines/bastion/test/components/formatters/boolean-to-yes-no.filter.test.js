describe('Filter:booleanToYesNo', function() {
    var filter;

    beforeEach(module('Bastion.components.formatters'));

    beforeEach(module(function($provide) {
        $provide.value('translate',  function(a) {return a});
    }));

    beforeEach(inject(function($filter) {
        filter = $filter('booleanToYesNo');
    }));

    it("returns 'Yes' for true, and 'No' for false", function() {
        expect(filter(true)).toBe('Yes');
        expect(filter(false)).toBe('No');
    });

    it("returns an empty string for null", function() {
        expect(filter()).toBe('');
        expect(filter('')).toBe('');
    });

    it("allows Yes and No to be overriden", function() {
        expect(filter(true, 'ok', 'fail')).toBe('ok');
        expect(filter(false, 'ok', 'fail')).toBe('fail');
    });

});
