describe('Filter:roundUp', function() {
    var roundUpFilter;

    beforeEach(module('Bastion.utils'));

    beforeEach(inject(function($filter) {
        roundUpFilter = $filter('roundUp')
    }));

    it("should round up a value", function() {
        expect(roundUpFilter('730.5')).toEqual(731);
        expect(roundUpFilter('730.2')).toEqual(731);
    });
});
