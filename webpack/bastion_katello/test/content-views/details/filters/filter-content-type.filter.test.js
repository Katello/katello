describe('Filter: filterContentType', function() {
    var filterContentTypeFilter;

    beforeEach(module('Bastion.content-views'));

    beforeEach(module(function ($provide) {
        $provide.value('translate', function (string) { return string; });
    }));

    beforeEach(inject(function($filter) {
        filterContentTypeFilter = $filter('filterContentType');
    }));

    it("provides a filter shell around transforming content type for a filter", function() {
        expect(filterContentTypeFilter('rpm')).toBe('RPM');
    });

});
