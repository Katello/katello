describe('Directive: errataCounts', function() {
    var $scope, $compile, element;

    beforeEach(module(
        'Bastion.errata',
        'errata/views/errata-counts.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_;
    }));

    beforeEach(function() {
        $scope.errataCounts = {bufix: 1, enhancement: 2, security: 3, total: 6};
        element = '<span errata-counts="errataCounts"></span>';
        element = $compile(element)($scope);
        $scope.$digest();
    });

    it("displays totals for each type of errata", function() {
        expect(element.find('[title="Security"]').length).toBe(1);
        expect(element.find('[title="Bug Fix"]').length).toBe(1);
        expect(element.find('[title="Enhancement"]').length).toBe(1);
    });

    it("displays icons for each type of errata", function() {
        expect(element.find('.fa-warning').length).toBe(1);
        expect(element.find('.fa-bug').length).toBe(1);
        expect(element.find('.fa-plus-square').length).toBe(1);
    });
});
