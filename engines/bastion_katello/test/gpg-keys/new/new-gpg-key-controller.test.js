describe('Controller: NewGPGKeyController', function() {
    var $scope, translate, GlobalNotification;

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
        GlobalNotification = $injector.get('GlobalNotification');

        $scope.table = {
            addRow: function() {},
            closeItem: function() {}
        };

        $controller('NewGPGKeyController', {
            $scope: $scope,
            GPGKey: GPGKey,
            CurrentOrganization:CurrentOrganization,
            GlobalNotification: GlobalNotification,
        });

    }));

    it('should attach a  gpg key resource on to the scope', function() {
        expect($scope.gpgKey).toBeDefined();
    });

    it('should save a new gpg key resource', function() {
        spyOn($scope.table, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(GlobalNotification, "setErrorMessage");
        $scope.uploadContent({"status": "success"});

        expect(GlobalNotification.setErrorMessage).not.toHaveBeenCalled();
        expect($scope.uploadStatus).toBe('success');

        expect($scope.table.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('gpgKeys.index');
    });

    it('should error on a new gpg key resource', function() {
        spyOn($scope.table, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(GlobalNotification, "setErrorMessage");
        $scope.uploadContent({"errors": "....", "displayMessage":"......"});

        expect(GlobalNotification.setErrorMessage).toHaveBeenCalled();

        expect($scope.uploadStatus).toBe('error');
        expect($scope.table.addRow).not.toHaveBeenCalled();
    });

});
