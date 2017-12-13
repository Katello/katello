describe('Controller: ContentCredentialDetailsInfoController', function() {
    var $scope, translate, Notification;

    beforeEach(module(
        'Bastion.content-credentials',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentCredential = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            contentCredentialId: 1
        };
        translate = function(message) {
            return message;
        };

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        $controller('ContentCredentialDetailsInfoController', {
            $scope: $scope,
            ContentCredential: ContentCredential,
            translate: translate,
            Notification: Notification
        });

    }));

    it('retrieves and puts a content credential on the scope', function() {
        expect($scope.contentCredential).toBeDefined();
    });

    it('should save a new content credential resource on upload', function() {
        spyOn(Notification, 'setSuccessMessage');

        spyOn($scope.contentCredential, '$get');
        $scope.uploadContent({"status": "success"});

        expect(Notification.setSuccessMessage).toHaveBeenCalled();

        expect($scope.uploadStatus).toBe('success');
        expect($scope.contentCredential.$get).toHaveBeenCalled();
    });

    it('should error on a new content credential resource on upload', function() {
        spyOn(Notification, 'setErrorMessage');

        spyOn($scope.contentCredential, '$get');
        $scope.uploadContent({"errors": "....", "displayMessage":"......"});

        expect(Notification.setErrorMessage).toHaveBeenCalled();
        expect($scope.contentCredential.$get).not.toHaveBeenCalled();
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

        spyOn(Notification, 'setErrorMessage');
        spyOn($scope.contentCredential, '$get');
        $scope.uploadError(error, text);

        expect(Notification.setErrorMessage).toHaveBeenCalledWith('Error during upload: File too large.');
        expect($scope.uploadStatus).toBe('error');
        expect($scope.contentCredential.$get).not.toHaveBeenCalled();
    });
});
