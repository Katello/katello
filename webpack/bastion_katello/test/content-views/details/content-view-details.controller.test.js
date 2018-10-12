describe('Controller: ContentViewDetailsController', function() {
    var $scope, ContentView, newContentView, Notification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            translate = $injector.get('translateMock'),
            RepositoryTypesService = {};

        newContentView = {id: 7};
        ContentView = $injector.get('MockResource').$new();
        ContentView.copy = function(params, success){success(newContentView)};

        RepositoryTypesService.repositoryTypeEnabled = function(){};
        ContentViewVersion = $injector.get('MockResource').$new();
        AggregateTask = {newAggregate: function(){}};

        Notification = {
            setSuccessMessage: function () {}
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.translate = function (value) { return value;}

        $scope.$stateParams = {contentViewId: 1};
        $scope.table = {};

        $controller('ContentViewDetailsController', {
            $scope: $scope,
            ContentView: ContentView,
            ContentViewVersion: ContentViewVersion,
            AggregateTask: AggregateTask,
            translate: translate,
            Notification: Notification,
            RepositoryTypesService: RepositoryTypesService
        });
    }));

    it("retrieves and puts the content view on the scope", function() {
        expect($scope.contentView).toBeDefined();
    });

    it("stores repositoryTypeEnabled on the scope", function() {
        expect($scope.repositoryTypeEnabled).toBeDefined();
    });

    it('provides a method to save a product', function() {
        spyOn(Notification, 'setSuccessMessage');

        $scope.save($scope.contentView);

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

    it('should be able to copy the content view', function(){
        spyOn($scope, 'transitionTo');
        $scope.copy(name);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-view.info', {contentViewId: newContentView.id});
    });

    it("provides a method to get the available versions for a composite", function () {
        var cv = {
            versions: [{id: 100, version: "foo"}],
            latest_version: "foo"
        }, response = $scope.getAvailableVersions(cv);

        expect(response[0].id).toBe("latest");
        expect(response[1].id).toBe(100);
        expect(response[1].version).toBe("foo");
    });
});
