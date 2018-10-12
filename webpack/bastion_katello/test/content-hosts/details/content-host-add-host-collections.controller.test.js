describe('Controller: ContentHostAddHostCollectionsController', function() {
    var $scope,
        $controller,
        translate,
        Host,
        HostCollection,
        CurrentOrganization;

    beforeEach(module(
        'Bastion.content-hosts',
        'Bastion.host-collections',
        'Bastion.test-mocks',
        'content-hosts/details/views/content-host-host-collections.html',
        'content-hosts/views/content-hosts.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        Host = $injector.get('MockResource').$new();
        HostCollection = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();

        Host.updateHostCollections = function() {};

        CurrentOrganization = 'foo';

        translate = function(message) {
            return message;
        };

        $scope.host = new Host({
            id: 1,
            host_collections: [{id: 1, name: "lalala"}]
        });

        $controller('ContentHostAddHostCollectionsController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            Host: Host,
            HostCollection: HostCollection,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it("allows adding host collections to the content host", function() {
        spyOn(Host, 'updateHostCollections');

        $scope.table.getSelected = function() {
            return [{id: 2, name: "hello!"}];
        };

        $scope.addHostCollections($scope.host);
        expect(Host.updateHostCollections).toHaveBeenCalledWith({id: 1}, {host_collection_ids: [1, 2]},
            jasmine.any(Function), jasmine.any(Function));
    });
});
