describe('Filter:upstreamPasswordFilter', function() {
    var filter, repository;

    beforeEach(module('Bastion.components.formatters'));

    beforeEach(inject(function($filter) {
        filter = $filter('upstreamPasswordFilter');
    }));

    it("returns username/*** for upstream_auth_exists = true", function() {
        repository = {
            "upstream_auth_exists" : true,
            "upstream_username" : "test_user"
        }
        expect(filter("", repository)).toBe('test_user / ********'); 
    });

    it("returns null for upstream_auth_exists = false", function() {
        repository = {
            "upstream_auth_exists" : false
        }
        expect(filter("", repository)).toBe(null);
    });
});
