describe('Controller: ContentViewDetailsController', function() {
    var $scope,
        ContentView,
        newContentView;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            translate = $injector.get('translateMock');

        newContentView = {id: 7};
        ContentView = $injector.get('MockResource').$new();
        ContentView.copy = function(params, success){success(newContentView)};

        ContentViewVersion = $injector.get('MockResource').$new();
        AggregateTask = {newAggregate: function(){}};

        $scope = $injector.get('$rootScope').$new();
        $scope.translate = function (value) { return value;}

        $scope.$stateParams = {contentViewId: 1};
        $scope.table = {
            addRow: function() {}
        };

        $controller('ContentViewDetailsController', {
            $scope: $scope,
            ContentView: ContentView,
            ContentViewVersion: ContentViewVersion,
            AggregateTask: AggregateTask,
            translate: translate
        });
    }));

    it("retrieves and puts the content view on the scope", function() {
        expect($scope.contentView).toBeDefined();
    });

    it("defines a method for deloading the versions", function() {
        expect($scope.reloadVersions).toBeDefined();
    });

    it('provides a method to save a product', function() {
        $scope.save($scope.contentView);

        expect($scope.successMessages.length).toBe(1);
    });

    it('should be able to copy the content view', function(){
        spyOn($scope, 'transitionTo');
        spyOn($scope.table, 'addRow');
        $scope.copy(name);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.info', {contentViewId: newContentView.id});
        expect($scope.table.addRow).toHaveBeenCalledWith(newContentView);
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
