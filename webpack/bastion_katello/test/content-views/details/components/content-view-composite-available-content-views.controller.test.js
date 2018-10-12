describe('Controller: ContentViewCompositeAvailableContentViewsController', function() {
    var $scope, ContentViewComponent, expectedVars;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'Bastion.i18n'));
    beforeEach(inject(function($injector) {
        var Nutupane,
            $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new();

        expectedVars = {
            versionId: 2,
            latestContentViewId: 3,
            latestNoVersionContentViewId: 3,
            compositeContentViewId: 1
        };
        ContentViewComponent = $injector.get('MockResource').$new();

        Nutupane = function () {
            this.getAllSelectedResults = function () {
                return {
                    included: {
                        resources: [
                            {versionId: expectedVars.versionId},
                            {versionId: "latest", id: expectedVars.latestContentViewId},
                            {id: expectedVars.latestNoVersionContentViewId},
                        ]
                    }
                };
            };

            this.load = function () {};
            this.table = {};
            this.setParams = function () {};
            this.refresh = function () {};
        };
        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: expectedVars.compositeContentViewId});
        $scope.saveError = function () {};

        ContentViewComponent.addComponents = function () {
            return {
                then: function () {}
            };
        };

        spyOn(ContentViewComponent, 'addComponents').and.callThrough();

        $controller('ContentViewCompositeAvailableContentViewsController', {
            $scope: $scope,
            Nutupane: Nutupane,
            CurrentOrganization: 'ACME_Corporation',
            ContentView: ContentView,
            ContentViewComponent: ContentViewComponent
        });
    }));

    it("puts a content view table on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it('provides a method to add components views to a composite content view', function() {
        var expectedParams = {
            compositeContentViewId: expectedVars.compositeContentViewId,
            components: [{"content_view_version_id": expectedVars.versionId},
                      {latest: true, "content_view_id": expectedVars.latestContentViewId},
                      {latest: true, "content_view_id": expectedVars.latestNoVersionContentViewId}]
        };
        $scope.addContentViews();
        expect(ContentViewComponent.addComponents).toHaveBeenCalledWith(expectedParams, jasmine.any(Function), jasmine.any(Function));
    });

});
