describe('Controller: GPGKeyProductsController', function() {
    var $scope;

    beforeEach(module(
        'Bastion.gpg-keys',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            GPGKey = $injector.get('MockResource').$new(),
            Nutupane;

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            gpgKeyId: 1
        };

        Nutupane = function() {
            this.table = {};
        };

        $controller('GPGKeyProductsController', {
            $scope: $scope,
            Nutupane: Nutupane,
            GPGKey: GPGKey
        });

    }));

    it('retrieves and puts a gpg key on the scope', function() {
        expect($scope.gpgKey).toBeDefined();
    });

    it("sets up the gpg key products nutupane table", function() {
        expect($scope.table).toBeDefined();
    });
});
