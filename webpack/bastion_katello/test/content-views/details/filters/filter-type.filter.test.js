describe('Filter: filterType', function() {
    var filterTypeFilter;

    beforeEach(module('Bastion.content-views'));

    beforeEach(module(function ($provide) {
        $provide.value('translate', function (string) { return string; });
    }));

    beforeEach(inject(function($filter) {
        filterTypeFilter = $filter('filterType');
    }));

    it("provides a filter shell around transforming type for a filter", function() {
        expect(filterTypeFilter(true)).toBe('Include');
    });

});
