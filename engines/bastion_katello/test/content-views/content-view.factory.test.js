describe('Factory: ContentView', function() {
    var $httpBackend,
        ContentView,
        contentViews;

    beforeEach(module('Bastion.content-views', 'Bastion.utils', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        contentViews = {
            results: [
                { name: 'ContentView1', id: 1 },
                { name: 'ContentView2', id: 2 }
            ],
            total: 10,
            subtotal: 5,
            limit: 5,
            offset: 0
        };

        $provide.value('CurrentOrganization', 'ACME');
        $provide.value('translate', function(string) {return string;})
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ContentView = $injector.get('ContentView');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a collection of content views', function() {
        $httpBackend.expectGET('katello/api/v2/content_views?organization_id=ACME')
                    .respond(contentViews);

        ContentView.queryPaged(function (response) {
            var views = response;

            expect(views.results.length).toBe(2);
            expect(views.total).toBe(10);
            expect(views.subtotal).toBe(5);
            expect(views.offset).toBe(0);
        });
    });

    it('provides a way to get a single content view', function() {
        $httpBackend.expectGET('katello/api/v2/content_views/1?organization_id=ACME')
                    .respond(contentViews.results[0]);

        ContentView.get({id: 1}, function (contentView) {
            expect(contentView).toBeDefined();
            expect(contentView.name).toEqual('ContentView1');
        });
    });

    it('provides a way to create a content view', function() {
        var contentView = {id: 1, name: 'Content View'};

        $httpBackend.expectPOST('katello/api/v2/content_views/1?organization_id=ACME')
                    .respond(contentView);

        ContentView.save(contentView, function (contentView) {
            expect(contentView).toBeDefined();
            expect(contentView.name).toEqual('Content View');
        });
    });

    it('provides a way to copy a content view', function() {
        var contentView = {id: 1, name: 'New Content View'};

        $httpBackend.expectPOST('katello/api/v2/content_views/1/copy?organization_id=ACME')
            .respond(contentView);

        ContentView.copy(contentView, function (contentView) {
            expect(contentView).toBeDefined();
            expect(contentView.name).toEqual('New Content View');
        });
    });

    it('provides a way to update a content view', function() {
        $httpBackend.expectPUT('katello/api/v2/content_views/1?organization_id=ACME')
                    .respond(contentViews.results[0]);

        ContentView.update({id: 1, name: 'NewCVName'}, function (contentView) {;
            expect(contentView).toBeDefined();
        });
    });
});
