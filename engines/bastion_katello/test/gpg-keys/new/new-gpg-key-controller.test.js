describe('Controller: NewGPGKeyController', function() {
    var $scope, translate, Notification;

    beforeEach(module(
        'Bastion.gpg-keys',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            GPGKey = $injector.get('MockResource').$new(),
            CurrentOrganization = "Foo";

        $scope = $injector.get('$rootScope').$new();
        Notification = $injector.get('Notification');

        $scope.table = {
            addRow: function() {},
            closeItem: function() {}
        };

        $controller('NewGPGKeyController', {
            $scope: $scope,
            GPGKey: GPGKey,
            CurrentOrganization:CurrentOrganization,
            Notification: Notification
        });

    }));

    it('should attach a  gpg key resource on to the scope', function() {
        expect($scope.gpgKey).toBeDefined();
    });

    it('should save a new gpg key resource', function() {
        spyOn($scope, 'transitionTo');
        spyOn(Notification, "setSuccessMessage");
        $scope.uploadContent({"status": "success"});

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.uploadStatus).toBe('success');

        expect($scope.transitionTo).toHaveBeenCalledWith('gpg-key.info', jasmine.any(Object));
    });

    it('should error on a new gpg key resource', function() {
        spyOn($scope, 'transitionTo');
        spyOn(Notification, "setSuccessMessage");
        spyOn(Notification, 'setErrorMessage');

        $scope.uploadContent({"errors": "....", "displayMessage":"......"});

        expect(Notification.setSuccessMessage).not.toHaveBeenCalled();
        expect(Notification.setErrorMessage).toHaveBeenCalled();

        expect($scope.uploadStatus).toBe('error');
    });

});
