describe('Controller: NewContentCredentialController', function() {
    var $scope, translate, Notification;

    beforeEach(module(
        'Bastion.content-credentials',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            ContentCredential = $injector.get('MockResource').$new(),
            CurrentOrganization = "Foo";

        $scope = $injector.get('$rootScope').$new();
        Notification = $injector.get('Notification');

        $scope.table = {
            addRow: function() {},
            closeItem: function() {}
        };

        $controller('NewContentCredentialController', {
            $scope: $scope,
            ContentCredential: ContentCredential,
            CurrentOrganization:CurrentOrganization,
            Notification: Notification
        });

    }));

    it('should attach a content credential resource on to the scope', function() {
        expect($scope.contentCredential).toBeDefined();
    });

    it('should save a new content credential resource', function() {
        spyOn($scope, 'transitionTo');
        spyOn(Notification, "setSuccessMessage");
        $scope.uploadContent({"status": "success"});

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.uploadStatus).toBe('success');

        expect($scope.transitionTo).toHaveBeenCalledWith('content-credential.info', jasmine.any(Object));
    });

    it('should error on a new content credential resource', function() {
        spyOn($scope, 'transitionTo');
        spyOn(Notification, "setSuccessMessage");
        spyOn(Notification, 'setErrorMessage');

        $scope.uploadContent({"errors": "....", "displayMessage":"......"});

        expect(Notification.setSuccessMessage).not.toHaveBeenCalled();
        expect(Notification.setErrorMessage).toHaveBeenCalled();

        expect($scope.uploadStatus).toBe('error');
    });

});
