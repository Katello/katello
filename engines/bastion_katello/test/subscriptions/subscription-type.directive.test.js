describe('Directive: subscriptionType', function() {
    var $scope, $compile, element;

    function removeExtraSpaces(string) {
        return string.trim().replace(/(?:\r\n|\r|\n|\t)/g, '').replace(/\s\s+/g, ' ');
    }
    
    beforeEach(module(
        'Bastion.subscriptions',
        'subscriptions/views/subscription-type.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_;
    }));

    it("subscription type Virtual when no host", function() {
        $scope.subscription = {virt_only: true};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(removeExtraSpaces(element.text())).toEqual("Virtual");
    });

    it("subscription type Physical when no host", function() {
        $scope.subscription = {virt_only: false};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(removeExtraSpaces(element.text())).toEqual("Physical");
    });

    it("subscription type Virtual when host", function() {
        $scope.subscription = {virt_only: false, host: {}};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(removeExtraSpaces(element.text())).toEqual("Physical");
    });

    it("subscription type Guest when host", function() {
        $scope.subscription = {virt_only: true, host: {id: 123, name: "hypervisor"}};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(removeExtraSpaces(element.text())).toEqual("Guests of hypervisor");
    });

    it("subscription type Temporary when unmapped_guest is true", function() {
        $scope.subscription = {virt_only: true, unmapped_guest: true};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(removeExtraSpaces(element.text())).toEqual("Temporary");
    });

    it("subscription type Temporary when unmapped_guest is false", function() {
        $scope.subscription = {virt_only: true, unmapped_guest: false};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(removeExtraSpaces(element.text())).toEqual("Virtual");
    });
});
