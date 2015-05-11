describe('Factory: ContentHost', function() {
    var ContentHost,
        releaseVersions,
        availableSubscriptions,
        contentHostsCollection;

    beforeEach(module('Bastion.content-hosts', 'Bastion.utils'));

    beforeEach(module(function($provide) {
        contentHostsCollection = {
            results: [
                { name: 'ContentHost1', id: 1 },
                { name: 'ContentHost2', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };

        releaseVersions = ['RHEL 6', 'Burrito'];
        availableSubscriptions = ['subscription1', 'subscription2'];

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function(_ContentHost_) {
        ContentHost = _ContentHost_;
    }));

    it("provides a way to update a content host", function() {
        var contentHost = contentHostsCollection.results[0];
        contentHost.name = 'NewContentHostName';
        $httpBackend.expectPUT('/katello/api/systems').respond(contentHost);

        ContentHost.update({name: 'NewContentHostName', id: 1}, function (contentHost) {
            expect(contentHost.name).toEqual('NewContentHostName');
        });
    });

    it("provides a way to get the possible release versions for a content host", function() {
        $httpBackend.expectGET('/katello/api/systems').respond(contentHostsCollection.results[0]);

        ContentHost.releaseVersions({ id: contentHostsCollection.results[0].id }, function (data) {
            expect(data).toEqual(releaseVersions);
        });
    });

    it("provides a way to get the available subscriptions for a content host", function() {
        $httpBackend.expectGET('/katello/api/systems').respond(availableSubscriptions);

        ContentHost.subscriptions({ id: contentHostsCollection.results[0].id }, function (data) {
            expect(data).toEqual(availableSubscriptions);
        });
    });

    it('ContentHost.contentOverride PUT /api/v2/content_hosts/1/content_override', function() {
        $httpBackend.expectPUT('/katello/api/v2/content_hosts/1/content_override').respond(contentHostsCollection.results[0]);

        ContentHost.contentOverride({id: 1},
                        {'content_override': { 'content_label': 'my-repository-label',
                                               name: "enabled",
                                               value: 1}
                        },
                        function(response) {
                            expect(response).toBeDefined();
                        });
    });

});
