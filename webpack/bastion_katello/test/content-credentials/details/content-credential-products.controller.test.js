describe('Controller: ContentCredentialProductsController', function() {
    var $scope;

    beforeEach(module(
        'Bastion.content-credentials',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            ContentCredential = $injector.get('MockResource').$new(),
            Nutupane;

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            contentCredentialId: 1
        };

        Nutupane = function() {
            this.table = {};
        };

        $controller('ContentCredentialProductsController', {
            $scope: $scope,
            Nutupane: Nutupane,
            ContentCredential: ContentCredential
        });

    }));

    it('retrieves and puts a content credential on the scope', function() {
        expect($scope.contentCredential).toBeDefined();
    });

    it("sets up the content credential products nutupane table", function() {
        expect($scope.table).toBeDefined();
    });
});
