describe('Filter:urlencode', function() {
    var urlencodeFilter;

    beforeEach(module('Bastion.utils'));

    beforeEach(inject(function($filter) {
        urlencodeFilter = $filter('urlencode')
    }));

    it("should encode a url", function() {
        expect(urlencodeFilter('=')).toEqual('%3D');
    });
});
