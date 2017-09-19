describe('Factory: Subscription', function() {
    var $httpBackend,
        Subscription,
        subscription,
        subscriptions;

    beforeEach(module('Bastion.subscriptions', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        subscriptions = {
            results: [
                { name: 'subscription1', id: 1 },
                { name: 'subscription2', id: 2 }
            ],
            total: 3,
            subtotal: 2
        };
        subscription = _.first(subscriptions.results);

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Subscription = $injector.get('Subscription');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of subscriptions', function() {
        $httpBackend.expectGET('katello/api/v2/organizations/ACME/subscriptions').respond(subscriptions);

        Subscription.queryPaged(function(subscriptions) {
            expect(subscriptions.results.length).toBe(2);
        });
    });

    it('provides a way to get a subscription', function() {
        $httpBackend.expectGET('katello/api/v2/organizations/ACME/subscriptions/1').respond(subscription);
        Subscription.get({ id: 1 }, function(results) {
            expect(results.id).toBe(subscription.id);
        });
    });

    it('provides a way to get a manifest history', function() {
        $httpBackend.expectGET('katello/api/v2/organizations/ACME/subscriptions/manifest_history').respond([]);
        Subscription.manifestHistory(function(result){
            expect(result).not.toBeUndefined();
        });
    });
});
