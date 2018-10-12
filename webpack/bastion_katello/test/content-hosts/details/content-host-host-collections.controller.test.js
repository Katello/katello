describe('Controller: ContentHostHostCollectionsController', function() {
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
            id: 2,
            host_collections: [{id: 1, name: "lalala"}, {id: 2, name: "hello!"}]
        });

        $controller('ContentHostHostCollectionsController', {
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

    it("allows removing host collections from the content host", function() {
        spyOn(Host, 'updateHostCollections');

        $scope.table.getSelected = function() {
            return [{id: 1, name: "lalala"}];
        };

        $scope.removeHostCollections($scope.host);
        expect(Host.updateHostCollections).toHaveBeenCalledWith({id: 2}, {host_collection_ids: [2]},
            jasmine.any(Function), jasmine.any(Function));
    });
});
