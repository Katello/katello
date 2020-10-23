describe('Controller: DebController', function() {
    var $scope, Deb, Host, fakeDeb, currentOrganization;

    beforeEach(module('Bastion.debs', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        currentOrganization = 'myOrg';
        fakeDeb = {name: 'foo', version: '1.0', architecture: 'greatestArch'};
        Deb = $injector.get('MockResource').$new();
        Host = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {debId: 1};
        $scope.deb = fakeDeb;
        Host.get = function(params, success, failure) {
          success({subtotal: 5})
        };


        $controller('DebController', {
            $scope: $scope,
            Deb: Deb,
            Host: Host,
            CurrentOrganization: currentOrganization
        });
    }));

    it("gets the content host using the host collection service and puts it on the $scope.", function() {
        expect($scope.deb).toBeDefined();
    });
});
