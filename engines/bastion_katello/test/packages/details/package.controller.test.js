describe('Controller: PackageController', function() {
    var $scope, Package, Host, fakePackage, currentOrganization;

    beforeEach(module('Bastion.packages', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        currentOrganization = 'myOrg';
        fakePackage = {name: 'foo', version: '1.0', release: '2', arch: 'greatestArch'};
        Package = $injector.get('MockResource').$new();
        Host = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {packageId: 1};
        $scope.package = fakePackage;
        Host.get = function(params, success, failure) {
          success({subtotal: 5})
        };


        $controller('PackageController', {
            $scope: $scope,
            Package: Package,
            Host: Host,
            CurrentOrganization: currentOrganization,
            newHostDetailsUI: 'newHostDetailsUI',
            newHostsPage: 'true'
        });
    }));

    it("gets the content host using the host collection service and puts it on the $scope.", function() {
        expect($scope.package).toBeDefined();
    });

    it("can generate an installed package search string", function() {
        $scope.package = fakePackage;
        expect($scope.createSearchString('installed_package')).toBe("installed_package=foo-1.0-2.greatestArch")
        expect($scope.createSearchString('applicable_package')).toBe("applicable_package=foo-1.0-2.greatestArch")
    })

    it("generates new host URL with /new/hosts when newHostsPage is true", function() {
        $scope.package = fakePackage;
        $scope.newHostsPage = true;
        var url = $scope.newHostUrl('installed_package');
        var expectedSearch = encodeURIComponent($scope.createSearchString('installed_package'));
        expect(url).toBe('/new/hosts?search=' + expectedSearch);
    })

    it("generates new host URL with /hosts when newHostsPage is false", function() {
        $scope.package = fakePackage;
        $scope.newHostsPage = false;
        var url = $scope.newHostUrl('installed_package');
        var expectedSearch = encodeURIComponent($scope.createSearchString('installed_package'));
        expect(url).toBe('/hosts?search=' + expectedSearch);
    })

    it("fetches hosts counts", function() {
        $scope.package = fakePackage;

        spyOn(Host, 'get').and.callThrough();

        $scope.fetchHostCount();
        expect(Host.get).toHaveBeenCalledWith({per_page: 0, search: $scope.createSearchString('installed_package'), 'organization_id': currentOrganization},
            jasmine.any(Function));
        expect($scope.installedPackageCount).toBe(5)
    })

});
