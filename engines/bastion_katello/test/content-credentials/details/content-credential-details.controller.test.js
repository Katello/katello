describe('Controller: ContentCredentialDetailsController', function() {
    var $scope, translate, Notification;

    beforeEach(module(
        'Bastion.content-credentials',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
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

        $scope.removeRow = function(id) {};
        $scope.table = {
            replaceRow: function() {}
        };

        $controller('ContentCredentialDetailsController', {
            $scope: $scope,
            ContentCredential: ContentCredential,
            $q: $q,
            translate: translate,
            Notification: Notification
        });

    }));

    it('retrieves and puts a content credential on the scope', function() {
        expect($scope.contentCredential).toBeDefined();
    });

    it('should save the content credential and return a promise', function() {
        var promise = $scope.save($scope.contentCredential);

        expect(promise.then).toBeDefined();
    });

    it('should save the content credential successfully', function() {
        spyOn(Notification, 'setSuccessMessage');

        $scope.save($scope.contentCredential);

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

    it('should fail to save the content credential', function() {
        spyOn(Notification, 'setErrorMessage');

        $scope.contentCredential.failed = true;
        $scope.save($scope.contentCredential);

        expect(Notification.setErrorMessage).toHaveBeenCalled();
    });

    it('should provide a way to remove a content credential', function() {
        spyOn($scope, 'transitionTo');
        $scope.removeContentCredential($scope.contentCredential);
        expect($scope.transitionTo).toHaveBeenCalledWith('content-credentials');
    });

});
