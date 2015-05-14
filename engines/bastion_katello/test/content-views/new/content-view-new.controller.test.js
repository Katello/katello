describe('Controller: NewContentViewController', function() {
    var $scope,
        $controller,
        dependencies,
        FormUtils,
        ContentView;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        $controller = $injector.get('$controller');

        ContentView = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        FormUtils = {
            labelize: function () {}
        };

        $scope.contentViewForm = $injector.get('MockForm');
        $scope.$parent.table = {addRow: function () {}};

        dependencies = {
            $scope: $scope,
            ContentView: ContentView,
            FormUtils: FormUtils,
            CurrentOrganization: 'CurrentOrganization'
        };

        $controller('NewContentViewController', dependencies);
    }));

    it('should attach a new content view resource on to the scope', function() {
        expect($scope.contentView).toBeDefined();
    });

    it('should save a new content view resource', function() {
        var contentView = $scope.contentView;

        spyOn($scope.$parent.table, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(contentView, '$save').andCallThrough();
        $scope.save(contentView);

        expect(contentView.$save).toHaveBeenCalled();
        expect($scope.$parent.table.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.repositories.yum.available',
                                                         {contentViewId: 1})
    });

    it("should save a new composite content view resource", function () {
        var contentView = $scope.contentView;
        spyOn($scope.$parent.table, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(contentView, '$save').andCallThrough();

        contentView.composite = true;
        $scope.save(contentView);

        expect(contentView.$save).toHaveBeenCalled();
        expect($scope.$parent.table.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.composite-content-views.available',
            {contentViewId: 1})
    });

    it('should fetch a label whenever the name changes', function() {
        spyOn(FormUtils, 'labelize');

        $scope.contentView.name = 'ChangedName';
        $scope.$apply();

        expect(FormUtils.labelize).toHaveBeenCalled();
    });
});

