describe('Factory: Filter', function() {
    var $httpBackend,
        filters;

    beforeEach(module('Bastion.content-views', 'Bastion.utils', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        filters = {
            results: [
                { name: 'Filter1', id: 1 },
                { name: 'Filter2', id: 2 }
            ],
            total: 10,
            subtotal: 5,
            limit: 5,
            offset: 0
        };
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Filter = $injector.get('Filter');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a collection of filters', function() {
        $httpBackend.expectGET('katello/api/v2/content_view_filters?content_view_id=1')
                    .respond(filters);

        Filter.queryPaged({'content_view_id': 1}, function (response) {
            var views = response;

            expect(views.results.length).toBe(2);
            expect(views.total).toBe(10);
            expect(views.subtotal).toBe(5);
            expect(views.offset).toBe(0);
        });
    });

    it('provides a way to get a single filter', function() {
        $httpBackend.expectGET('katello/api/v2/content_view_filters/1?content_view_id=1')
                    .respond(filters.results[0]);

        Filter.get({'content_view_id': 1, filterId: 1}, function (filter) {
            expect(filter).toBeDefined();
            expect(filter.name).toEqual('Filter1');
        });
    });

    it('provides a way to create a filter', function() {
        var filter = {id: 1, name: 'Filter'};

        $httpBackend.expectPOST('katello/api/v2/content_view_filters/1?content_view_id=1')
                    .respond(filter);

        Filter.save({'content_view_id': 1}, filter, function (filter) {
            expect(filter).toBeDefined();
            expect(filter.name).toEqual('Filter');
        });
    });

    it('provides a way to update a filter', function() {
        $httpBackend.expectPUT('katello/api/v2/content_view_filters/1?content_view_id=1')
                    .respond(filters.results[0]);

        Filter.update({'content_view_id': 1}, {id: 1, name: 'New Filter Name'}, function (filter) {
            expect(filter).toBeDefined();
        });
    });

    it('provides a way to get installable errata for a filter', function() {
        $httpBackend.expectGET('katello/api/v2/content_view_filters/1/errata?available_for=content_view_filter')
                    .respond({});

        Filter.availableErrata({'filterId': 1}, function (errata) {
            expect(errata).toBeDefined();
        });
    });

    it('provides a way to retrieve current errata on a filter', function() {
        $httpBackend.expectGET('katello/api/v2/content_view_filters/1/errata?content_view_id=1')
                    .respond({});

        Filter.errata({'filterId': 1, 'content_view_id': 1}, function (errata) {
            expect(errata).toBeDefined();
        });
    });

});
