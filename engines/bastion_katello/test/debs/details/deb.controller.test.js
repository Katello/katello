describe('Controller: DebController', function() {
    var $scope, Deb, Host, fakeDeb, currentOrganization;

    beforeEach(module('Bastion.debs', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        currentOrganization = 'myOrg';
        fakeDeb = {name: 'foo', version: '1.0~deb9u1', architecture: 'greatestArch'};
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
            CurrentOrganization: currentOrganization,
            newHostDetailsUI: 'newHostDetailsUI'
        });
    }));

    it("gets the content host using the host collection service and puts it on the $scope.", function() {
        expect($scope.deb).toBeDefined();
    });

    it("can generate an installed deb search string", function() {
        $scope.deb = fakeDeb;
        expect($scope.createSearchString('installed_deb')).toBe(encodeURIComponent("installed_deb=\"foo:greatestArch=1.0~deb9u1\""))
        expect($scope.createSearchString('applicable_deb')).toBe(encodeURIComponent("applicable_deb=\"foo:greatestArch=1.0~deb9u1\""))
    })

    it("fetches hosts counts", function() {
        $scope.deb = fakeDeb;

        spyOn(Host, 'get').and.callThrough();

        $scope.fetchHostCount();
        expect(Host.get).toHaveBeenCalledWith({per_page: 0, search: decodeURIComponent($scope.createSearchString('installed_deb')), 'organization_id': currentOrganization},
            jasmine.any(Function));
        expect($scope.installedDebCount).toBe(5)
    })

});
