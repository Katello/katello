describe('Controller: GPGKeyDetailsInfoController', function() {
    var $scope, translate;

    beforeEach(module(
        'Bastion.gpg-keys',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            GPGKey = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            gpgKeyId: 1
        };
        translate = function(message) {
            return message;
        };

        $controller('GPGKeyDetailsInfoController', {
            $scope: $scope,
            GPGKey: GPGKey,
            translate: translate
        });

    }));

    it('retrieves and puts a gpg key on the scope', function() {
        expect($scope.gpgKey).toBeDefined();
    });

    it('should save a new gpg key resource on upload', function() {
        spyOn($scope.gpgKey, '$get');
        $scope.uploadContent({"status": "success"});

        expect($scope.errorMessage).not.toBeDefined();
        expect($scope.uploadStatus).toBe('success');
        expect($scope.gpgKey.$get).toHaveBeenCalled();
    });

    it('should error on a new gpg key resource on upload', function() {
        spyOn($scope.gpgKey, '$get');
        $scope.uploadContent({"errors": "....", "displayMessage":"......"});

        expect($scope.errorMessages).toBeDefined();
        expect($scope.uploadStatus).toBe('error');
        expect($scope.gpgKey.$get).not.toHaveBeenCalled();
    });
});
