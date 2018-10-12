describe('Filter:repositorySetsEnabledFilter', function() {
    var filter, repositorySet;

    beforeEach(module('Bastion.repository-sets'));

    beforeEach(module(function($provide) {
        repositorySet = {
            enabled_content_override: 'default',
            enabled: true
        };

        $provide.value('translate',  function(a) {return a});
    }));

    beforeEach(inject(function($filter) {
        filter = $filter('repositorySetsEnabled');
    }));

    it("handles enabled overridden", function() {
        repositorySet.enabled_content_override = true;
        repositorySet.enabled = false;
        expect(filter(repositorySet)).toBe('Enabled (overridden)');
    });

    it("handles disabled overridden", function() {
        repositorySet.enabled_content_override = false;
        repositorySet.enabled = true;
        expect(filter(repositorySet)).toBe('Disabled (overridden)');
    });

    it("handles enabled", function() {
        repositorySet.enabled_content_override = null;
        repositorySet.enabled = true;
        expect(filter(repositorySet)).toBe('Enabled');
    });

    it("handles disabled", function() {
        repositorySet.enabled_content_override = '123';
        repositorySet.enabled = false;
        expect(filter(repositorySet)).toBe('Disabled');
    });
});
