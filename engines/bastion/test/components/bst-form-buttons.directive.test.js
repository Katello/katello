describe('Directive: bstFormButtons', function() {
    var $scope, $compile, element;

    beforeEach(module(
        'Bastion.components',
        'components/views/bst-save-control.html',
        'components/views/bst-form-buttons.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_;
    }));

    beforeEach(function() {
        element = '<form name="testForm">' +
                    '<input name="name" ng-model="fake.name" required>' +
                    '<div bst-form-buttons ' +
                        'on-cancel="transitionTo(\'product.index\')" ' +
                        'on-save="save(product)" ' +
                        'working="working"> ' +
                   '</div>' +
                 '</form>';

        element = $compile(element)($scope);
        $scope.$digest();
    });

    it("should set create button to disabled if no server validator is set but the form is invalid", function() {
        var disabled = angular.element(element).find('.btn-primary').attr('disabled');
        expect(disabled).toBe('disabled');
    });

    it("should set create button to enabled if a server validator is set", function() {
        $scope.testForm.name.$error.server = true;
        $scope.$digest();
        var disabled = angular.element(element).find('.btn-primary').attr('disabled');
        expect(disabled).toBe(undefined);
    });

});
