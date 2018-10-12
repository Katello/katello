describe('Controller: ContentViewCompositeContentViewsListController', function() {
    var $scope, ContentViewComponent, expectedVars;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'Bastion.i18n'));

    beforeEach(inject(function($injector) {
        var Nutupane,
            $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new();


        expectedVars = {
            componentIds: [1,2],
            compositeContentViewId: 1
        };
        ContentViewComponent = $injector.get('MockResource').$new


        Nutupane = function () {
            this.getAllSelectedResults = function () {
                return {included: {ids: expectedVars.componentIds}};
            };

            this.table = {};
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: expectedVars.compositeContentViewId});
        $scope.saveError = function () {};
        ContentViewComponent.update = function () {};
        ContentViewComponent.removeComponents = function () {};
        $scope.translate = function (value) { return value;}

        $controller('ContentViewCompositeContentViewsListController', {
            $scope: $scope,
            Nutupane: Nutupane,
            CurrentOrganization: 'ACME_Corporation',
            ContentView: ContentView,
            ContentViewComponent: ContentViewComponent
        });
    }));

    it("puts a content view version table on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("provides a way to update the content view's version", function () {
        var newContentComponent = { id: 1, versionId: 100},
            expectedParams = {
                id: 1,
                "content_view_version_id": 100,
                compositeContentViewId: expectedVars.compositeContentViewId,
                latest: false
        };

        spyOn(ContentViewComponent, 'update').and.callThrough();
        $scope.saveContentViewComponent(newContentComponent);
        expect(ContentViewComponent.update).toHaveBeenCalledWith(expectedParams, jasmine.any(Function), jasmine.any(Function));
    });

    it("provides a way to update the content view's version to latest", function () {
        var newContentComponent = { id: 1, versionId: "latest"},
            expectedParams = {
                id: 1,
                compositeContentViewId: expectedVars.compositeContentViewId,
                latest: true
        };

        spyOn(ContentViewComponent, 'update').and.callThrough();
        $scope.saveContentViewComponent(newContentComponent);
        expect(ContentViewComponent.update).toHaveBeenCalledWith(expectedParams, jasmine.any(Function), jasmine.any(Function));
    });

    it('provides a method to remove content views from a composite content view', function() {
        var expectedParams = {
            compositeContentViewId: expectedVars.compositeContentViewId,
            "component_ids": expectedVars.componentIds
        };
        spyOn(ContentViewComponent, 'removeComponents').and.callThrough();
        $scope.removeContentViewComponents();

        expect(ContentViewComponent.removeComponents).toHaveBeenCalledWith(expectedParams, jasmine.any(Function), jasmine.any(Function));
    });

    it("provides a method to get the version string for the version selector", function () {
        var component = {
            latest: true,
            "content_view_version": {version : 100}
        };
        expect($scope.getVersionString(component)).toBe("Latest (Currently 100)");

        component.latest = false;
        expect($scope.getVersionString(component)).toBe("100");
    });
});
