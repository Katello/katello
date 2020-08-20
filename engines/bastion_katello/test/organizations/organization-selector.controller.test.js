describe('Controller: OrganizationSelectorController', function() {
    var $scope,
        $rootScope,
        $state,
        $window;

    beforeEach(module('Bastion.organizations', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Organization = $injector.get('MockResource').$new(),
            CurrentOrganization = undefined;

        $rootScope = $injector.get('$rootScope');
        $scope = $rootScope.$new();
        $state = $injector.get('$state');
        $window = {location: {href: ''}};

        Organization.select = function (params) {
            return {'$promise': { then: function (func) { func.call() } }};
        };

        $controller('OrganizationSelectorController', {
            $scope: $scope,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            $window: $window
        });
    }));

    it("should query for a list of organizations", function() {
        expect($scope.organizations).toBeDefined();
    });

    it("should provide selecting an organization in the backend", function () {
        $scope.$stateParams = {"toState": '/foo'};
        $scope.selectOrganization({id: 1, name: 'Default Organization'});

        expect($window.location.href).toBeDefined();
    });

});

