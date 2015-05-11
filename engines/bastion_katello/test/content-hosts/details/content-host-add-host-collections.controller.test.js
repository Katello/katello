describe('Controller: ContentHostAddHostCollectionsController', function() {
    var $scope,
        $controller,
        translate,
        ContentHost,
        CurrentOrganization;

    beforeEach(module(
        'Bastion.content-hosts',
        'Bastion.host-collections',
        'Bastion.test-mocks',
        'content-hosts/details/views/host-collections.html',
        'content-hosts/views/content-hosts.html',
        'content-hosts/views/content-hosts-table-full.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        ContentHost = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        ContentHost.saveHostCollections = function() {};

        CurrentOrganization = 'foo';

        translate = function(message) {
            return message;
        };

        $controller('ContentHostAddHostCollectionsController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            ContentHost: ContentHost,
            CurrentOrganization: CurrentOrganization
        });

        $scope.contentHost = new ContentHost({
            uuid: 2,
            hostCollections: [{id: 1, name: "lalala"}],
            host_collection_ids: [1]
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.hostCollectionsTable).toBeDefined();
    });

    it("allows adding host collections to the content host", function() {
        spyOn($scope.contentHost, '$update');

        $scope.hostCollectionsTable.getSelected = function() {
            return [{id: 2, name: "hello!"}];
        };

        $scope.addHostCollections($scope.contentHost);
        expect($scope.contentHost.$update).toHaveBeenCalledWith({id: 2}, jasmine.any(Function), jasmine.any(Function));
    });
});
