describe('Directive: bstFormGroup', function() {
    var $scope, $compile, element;

    beforeEach(module(
        'Bastion.components',
        'components/views/bst-form-group.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_;
    }));

    beforeEach(function() {
        element = '<form name="testForm">' +
                    '<div bst-form-group label="Name" required>' +
                        '<input id="name" ' +
                               'name="name" ' +
                               'ng-model="fake.name" ' +
                               'type="text" ' +
                               'tabindex="1" ' +
                               'required/>' +
                    '</div>' +
                 '</form>';

        $scope.fake = {name: ''};
        element = $compile(element)($scope);
        $scope.$digest();
    });

    it("should add a 'form-control' class to the input", function() {
        expect(element.find('input').hasClass('form-control')).toBe(true);
    });

    it("should display validation error messages if they exist", function() {
        $scope.testForm.name.$error.messages = ['Error message']
        $scope.$digest();

        expect(element.find('.help-block').hasClass('ng-hide')).toBe(false);
        expect(element.find('li').length).toBeGreaterThan(0);
    });

    it("should set the form group to an error state if the form is invalid and dirty", function() {
        $scope.testForm.name.$dirty = true;
        $scope.$digest();

        expect($scope.testForm.name.$invalid).toBe(true);
        expect($scope.testForm.name.$dirty).toBe(true);
        expect(element.find('.has-error').length).toBeGreaterThan(0);
    });

    it("should not set the form group to an error state if the form is invalid but not dirty", function() {
        expect(element.find('.has-errors').length).toBe(0);
    });

    it("should do nothing if valid and dirty", function() {
        $scope.testForm.name.$dirty = true;
        $scope.$digest();

        expect(element.find('.has-errors').length).toBe(0);
    });
});
