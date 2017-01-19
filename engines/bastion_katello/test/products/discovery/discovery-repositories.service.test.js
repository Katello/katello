describe('Service: DiscoveryRepositories', function () {
    var DiscoveryRepositories,
        rows, repositoryUrl, upstreamUsername, upstreamPassword;

    beforeEach(module('Bastion.products'));

    beforeEach(inject(function($injector) {
        rows = [1, 2, 3];
        repositoryUrl = 'http://fake/';
        upstreamUsername = 'username';
        upstreamPassword = 'password';
        DiscoveryRepositories = $injector.get('DiscoveryRepositories');
    }));

    it("provides a method to set rows.", function () {
        DiscoveryRepositories.setRows(rows);
        expect(DiscoveryRepositories.rows).toBe(rows);
    });

    it("provides a method to get rows.", function () {
        DiscoveryRepositories.rows = rows;
        expect(DiscoveryRepositories.getRows()).toBe(rows);
    });

    it("provides a method to set repositoryUrl.", function () {
        DiscoveryRepositories.setRepositoryUrl(repositoryUrl);
        expect(DiscoveryRepositories.repositoryUrl).toBe(repositoryUrl);
    });

    it("provides a method to get repositoryUrl.", function () {
        DiscoveryRepositories.repositoryUrl = repositoryUrl;
        expect(DiscoveryRepositories.getRepositoryUrl()).toBe(repositoryUrl);
    });

    it("provides a method to set upstreamUsername.", function () {
        DiscoveryRepositories.setUpstreamUsername(upstreamUsername);
        expect(DiscoveryRepositories.upstreamUsername).toBe(upstreamUsername);
    });

    it("provides a method to get upstreamUsername.", function () {
        DiscoveryRepositories.upstreamUsername = upstreamUsername;
        expect(DiscoveryRepositories.getUpstreamUsername()).toBe(upstreamUsername);
    });

    it("provides a method to set upstreamPassword.", function () {
        DiscoveryRepositories.setUpstreamPassword(upstreamPassword);
        expect(DiscoveryRepositories.upstreamPassword).toBe(upstreamPassword);
    });

    it("provides a method to get upstreamPassword.", function () {
        DiscoveryRepositories.upstreamPassword = upstreamPassword;
        expect(DiscoveryRepositories.getUpstreamPassword()).toBe(upstreamPassword);
    });

});
