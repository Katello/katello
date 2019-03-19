describe('Filter:arrayToString', function() {
    var array, arrayToStringFilter;

    beforeEach(module('Bastion.components.formatters'));

    beforeEach(inject(function($filter) {
        array = [
            'one',
            'two',
            'three'
        ];
        arrayToStringFilter = $filter('arrayToString');
    }));

    it("transforms an array to a string.", function() {
        expect(arrayToStringFilter(array)).toBe('one, two, three');
    });

    it("allows a custom separator", function() {
        expect(arrayToStringFilter(array, ':')).toBe('one:two:three');
    });
});
