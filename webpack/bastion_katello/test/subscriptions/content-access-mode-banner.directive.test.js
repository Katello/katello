describe('Directive: contentAccessModeBanner', function() {
    var $scope, element;

    beforeEach(module(
        'Bastion.subscriptions',
        'subscriptions/views/content-access-mode-banner.html'
    ));

    beforeEach(module(function($provide) {
        $provide.value('contentAccessMode', 'org_environment');
    }));

    beforeEach(inject(function($compile, $rootScope, $httpBackend) {
        //TODO: necessary because of https://github.com/theforeman/rfcs/pull/13
        $httpBackend.expectGET('/components/views/bst-alert.html').respond("");

        $scope = $rootScope.$new();
        element = angular.element('<div content-access-mode-banner></div>');
        $compile(element)($scope);
        $scope.$digest();
    }));

    it("set content access mode on the scope", function() {
        expect($scope.contentAccessMode).toEqual("org_environment");
    });
});
