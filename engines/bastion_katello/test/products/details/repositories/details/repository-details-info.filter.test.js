describe('Filter:upstreamPasswordFilter', function() {
    var filter, repository;

    beforeEach(module('Bastion.components.formatters'));

    beforeEach(inject(function($filter) {
        filter = $filter('upstreamPasswordFilter');
    }));

    it("returns *** for upstream_password_exists = true", function() {
        repository = {
            "upstream_password_exists" : true
        }
        expect(filter("", repository)).toBe('******');
    });

    it("returns null for upstream_password_exists = false", function() {
        repository = {
            "upstream_password_exists" : false
        }
        expect(filter("", repository)).toBe(null);
    });
});
