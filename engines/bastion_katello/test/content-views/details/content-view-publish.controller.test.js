describe('Controller: ContentViewPublishController', function() {
    var $scope;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock');

        ContentView.publish = function(options, callback) {  callback({id: 3}) };
        $scope = $injector.get('$rootScope').$new();
        $scope.reloadVersions = function () {};

        $scope.contentView = ContentView.get({id: 1});
        $scope.contentView.versions = [];
        $scope.$stateParams = {contentViewId: 1};
        $scope.fetchContentView = function() {};

        spyOn($scope, 'transitionTo');
        spyOn($scope, 'reloadVersions');

        $controller('ContentViewPublishController', {
            $scope: $scope,
            translate: translate,
            ContentView: ContentView
        });
    }));

    it("puts an empty version on the scope", function() {
        expect($scope.version).toBeDefined();
    });

    it('provides a method to publish a content view version', function() {
        $scope.publish($scope.contentView, $scope.version);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-view.versions',
            {contentViewId: $scope.contentView.id});
    });

});
