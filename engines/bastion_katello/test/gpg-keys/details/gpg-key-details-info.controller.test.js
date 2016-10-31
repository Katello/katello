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

    it('should handle a 413 error', function() {
        var error = 'Could not parse JSON',
            text = '<html><head> \
            <title>413 Request Entity Too Large</title> \
            </head><body> \
            <h1>Request Entity Too Large</h1> \
            The requested resource<br />/katello/api/v2/repositories/1/upload_content<br /> \
            does not allow request data with POST requests, or the amount of data provided in \
            the request exceeds the capacity limit. \
            </body></html>';

        spyOn($scope.gpgKey, '$get');
        $scope.uploadError(error, text);

        expect($scope.errorMessages).toBeDefined();
        expect($scope.errorMessages[0]).toBe('Error during upload: File too large.');
        expect($scope.uploadStatus).toBe('error');
        expect($scope.gpgKey.$get).not.toHaveBeenCalled();
    });
});
