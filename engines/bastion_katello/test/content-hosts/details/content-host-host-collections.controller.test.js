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
        'content-hosts/details/views/host-collections.html',
        'content-hosts/views/content-hosts.html',
        'content-hosts/views/content-hosts-table-full.html'
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

        $scope.contentHost = new Host({
            uuid: 2,
            hostCollections: [{id: 1, name: "lalala"}, {id: 2, name: "hello!"}],
            host_collection_ids: [1, 2],
            host: {
                id: 1
            }
        });

        $scope.contentHost.$promise = {
            then: function (callback) {
                callback($scope.contentHost);
            }
        };

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
        expect($scope.hostCollectionsTable).toBeDefined();
    });

    it("allows removing host collections from the content host", function() {
        spyOn(Host, 'updateHostCollections');

        $scope.hostCollectionsTable.getSelected = function() {
            return [{id: 1, name: "lalala"}];
        };

        $scope.removeHostCollections($scope.contentHost);
        expect(Host.updateHostCollections).toHaveBeenCalledWith({id: 1}, {host_collection_ids: [2]},
            jasmine.any(Function), jasmine.any(Function));
    });
});
