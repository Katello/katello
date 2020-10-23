describe('Controller: DebsController', function() {
    var $scope,
        $location,
        $controller,
        Deb,
        Task,
        Repository,
        Nutupane;

    beforeEach(module('Bastion.debs', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                params: {},
                showColumns: function() {}
            };
            this.get = function() {};
            this.refresh = function () {};
            this.getAllSelectedResults = function () {};
        };

        Task = {
            registerSearch: function() {},
            unregisterSearch: function () {}
        };
    });

    beforeEach(inject(function(_$controller_, $rootScope, _$location_, MockResource, translateMock) {
        Deb = MockResource.$new();
        Repository = MockResource.$new();
        $scope = $rootScope.$new();
        $location = _$location_;

        $controller = _$controller_;
        dependencies = {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            Deb: Deb,
            Task: Task,
            Repository: Repository,
            CurrentOrganization: 'CurrentOrganization',
            translate: translateMock
        };

        $controller('DebsController', dependencies);
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });
});
