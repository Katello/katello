describe('Factory: BstBookmark', function() {
    var $httpBackend,
        bookmarks,
        BstBookmark;

    beforeEach(module('Bastion.components'));

    beforeEach(module(function() {
        bookmarks = {
            results: [{name:"search1",
                       controller:"controller1",
                       query:"name  =  ak1",
                       public:null}],
            total: 1,
            subtotal: 1
        };
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        BstBookmark = $injector.get('BstBookmark');
    }));

    it('provides a way to create a bookmark', function() {
        $httpBackend.expectPOST('/api/v2/bookmarks').respond(bookmarks.results[0]);

        BstBookmark.create(function(bookmarks) {
            expect(response).toBeDefined();
        });
    });
});
