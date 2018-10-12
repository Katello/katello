describe('Directive: selectActionDropdown', function() {
    var element, elementScope;

    beforeEach(module(
        'Bastion.common',
        'common/views/select-action-dropdown.html'
    ));

    beforeEach(inject(function($compile, $rootScope) {
        var $scope = $rootScope.$new();
        element = angular.element('<div select-action-dropdown><ul id="blah"></ul></div>');
        $compile(element)($scope);
        $scope.$digest();
        elementScope = element.scope();
    }));

    it("should include a .btn-group that allows for toggling the dropdown", function () {
        expect(element.find('.btn-group').length).toBe(1);
        expect(element.find('button').length).toBe(2);
    });

    it("should transclude the contents of the directive", function () {
        expect(element.find('#blah').length).toBe(1);
    });

    it("should provide a status object that defaults to false", function () {
        expect(elementScope.status).toBeDefined();
        expect(elementScope.status.isOpen).toBe(false);
    });

    it("should provide a way to toggle the dropdown", function () {
        var event = {
            preventDefault: function () {},
            stopPropagation: function () {}
        };

        spyOn(event, 'preventDefault');
        spyOn(event, 'stopPropagation');

        elementScope.toggleDropdown(event);

        expect(event.preventDefault).toHaveBeenCalled();
        expect(event.stopPropagation).toHaveBeenCalled();
        expect(elementScope.status.isOpen).toBe(true);
    });
});

