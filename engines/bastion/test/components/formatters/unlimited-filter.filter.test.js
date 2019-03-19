describe('Filter:unlimitedFilter', function() {
    var unlimitedFilter;

    beforeEach(module('Bastion.components.formatters'));

    beforeEach(module(function($provide) {
        $provide.value('translate',  function(a) {return a});
    }));

    beforeEach(inject(function($filter) {
        unlimitedFilter = $filter('unlimitedFilter');
    }));

    it("ensures correctly transforms limit", function() {
        expect(unlimitedFilter(3, true)).toBe('Unlimited');
        expect(unlimitedFilter(2)).toBe('2');
    });

});
