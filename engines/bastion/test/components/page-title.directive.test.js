describe('Directive: setTitle', function () {
    var $scope, $compile, PageTitle, resource, element;

    beforeEach(module('Bastion.components', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
       PageTitle = {
           setTitle: function () {}
       };

       $provide.value('PageTitle', PageTitle);
    }));

    beforeEach(inject(function (_$compile_, _$rootScope_, MockResource) {
        $compile = _$compile_;
        $scope = _$rootScope_;
        resource = MockResource.$new().get({id: 1});
    }));

    it("should wait on a promise if the model is provided", function () {
        spyOn(PageTitle, 'setTitle');
        $scope.resource = resource;
        element = angular.element('<div page-title ng-model="resource">new awesome title</div>');

        $compile(element)($scope);
        expect(PageTitle.setTitle).not.toHaveBeenCalled();

        $scope.$digest();

        expect(PageTitle.setTitle).toHaveBeenCalledWith('new awesome title', jasmine.any(Object));
    });

    it("should set the page title without waiting for a $promise if none exists", function () {
        spyOn(PageTitle, 'setTitle');
        element = angular.element('<div page-title>new awesome title</div>');

        $compile(element)($scope);

        expect(PageTitle.setTitle).toHaveBeenCalledWith('new awesome title', jasmine.any(Object));
    });
});
