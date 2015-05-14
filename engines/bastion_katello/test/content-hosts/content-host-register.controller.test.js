describe('Controller: ContentHostRegisterController', function() {
    var $scope;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $location = $injector.get('$location'),
            Capsule = $injector.get('MockResource').$new(),
            BastionConfig = {consumerCertRPM: 'katello-ca.rpm'};

        $scope = $injector.get('$rootScope').$new();
        $controller('ContentHostRegisterController', {
            $scope: $scope,
            $location: $location,
            Capsule: Capsule,
            CurrentOrganization: 'ACME',
            BastionConfig: BastionConfig
        });
    }));

    it("puts the current organization on the scope", function() {
        expect($scope.organization).toBeDefined();
    });

    it('puts the current domain on the scope', function() {
        expect($scope.katelloHostname).toBeDefined();
    });

    it('should fetch a list of capsules', function(){
        expect($scope.capsules).toBeDefined();
        expect($scope.selectedCapsule).toBeDefined();
    });

});
