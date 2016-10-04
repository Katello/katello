describe('Controller: ContentViewVersionDeletionConfirmController', function() {
    var $scope, environments, version, ContentView;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        environments = [{name: 'dev'}];
        version = {id: 1, environments: environments};
        ContentView = $injector.get('MockResource').$new();
        ContentView.removeAssociations = function() {};

        spyOn(ContentView, 'removeAssociations');

        $scope = $injector.get('$rootScope').$new();
        $scope.validateEnvironmentSelection = function() {};

        $scope.selectedEnvironmentIds = function () {
            return _.map($scope.deleteOptions.environments, 'id');
        };

        $scope.contentView = {id: 8};

        $controller('ContentViewVersionDeletionConfirmController', {
            $scope: $scope,
            ContentView: ContentView,
            translate: function(){}
        });
    }));

    it("should call deletion correctly with environment ids", function() {
        var expected;
        $scope.deleteOptions = {
            deleteArchive: false,
            environments: [{id: 1}, {id: 2}],
            contentHosts: {contentView: {id: 9},
                      environment:  {id: 99}},
            activationKeys: {}
        };

        expected = {id : 8,
                    system_content_view_id : 9,
                    system_environment_id : 99,
                    environment_ids : [1, 2]};

        $scope.performDeletion();
        expect(ContentView.removeAssociations).toHaveBeenCalledWith(expected, jasmine.any(Function),
            jasmine.any(Function));
    });


    it("should call deletion correctly with environment ids and version id", function() {
        var expected;
        $scope.version = {id: 77};
        $scope.deleteOptions = {
            deleteArchive: true,
            environments: [{id: 1}, {id: 2}],
            contentHosts: {contentView: {id: 9},
                      environment:  {id: 99}},
            activationKeys: {}
        };

        expected = {id : 8,
                    system_content_view_id : 9,
                    system_environment_id : 99,
                    environment_ids : [1, 2],
                    content_view_version_ids: [77]};

        $scope.performDeletion();
        expect(ContentView.removeAssociations).toHaveBeenCalledWith(expected, jasmine.any(Function),
            jasmine.any(Function));
    });

});
