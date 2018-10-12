describe('Controller: ErratumContentHostsController', function() {
    var $scope, translate, Nutupane, IncrementalUpdate, ContentHostBulkAction,
        CurrentOrganization;

    beforeEach(module('Bastion.errata', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            MockResource = $injector.get('MockResource');

        translate = function (string) {
            return string;
        };

        Nutupane = function() {
            this.table = {
                params: {},
                showColumns: function () {},
                allResultsSelectCount: function () {}
            };
            this.enableSelectAllResults = function () {};
            this.getAllSelectedResults = function () {
                return {
                    included: {
                        ids: [1, 2, 3],
                        search: ""
                    }
                };
            };
            this.setParams = function (params) {
                this.table.params = params;
            };
            this.refresh = function () {};
            this.load = function () {
                return {then: function () {}}
            };
        };

        Host = {};

        ContentHostBulkAction = {
            failed: false,
            installContent: function (params, success, error) {
                if (this.failed) {
                    error({errors: ['error']});
                } else {
                    success();
                }
            }
        };

        IncrementalUpdate = {
            getIncrementalUpdates: function () {},
            getErrataIds: function () {},
            setBulkContentHosts: function () {},
            setErrataIds: function () {}
        };

        Environment = MockResource.$new();
        CurrentOrganization = 'foo';
        
        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {errataId: 1};
        $scope.checkIfIncrementalUpdateRunning = function () {};

        $controller('ErratumContentHostsController', {
            $scope: $scope,
            translate: translate,
            Nutupane: Nutupane,
            Host: Host,
            IncrementalUpdate: IncrementalUpdate,
            Environment: Environment,
            ContentHostBulkAction: ContentHostBulkAction,
            CurrentOrganization: CurrentOrganization                      
        });
    }));

    it("puts the errata content hosts table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("generates errata search string properly for single errata", function () {
        $scope.errata = {'errata_id': 'foo'};

        expect($scope.errataSearchString(false)).toBe('applicable_errata = "foo"');
        expect($scope.errataSearchString(true)).toBe('installable_errata = "foo"');
    });

    it("generates errata search string properly for multiple errata", function () {
        $scope.errata = undefined;
        spyOn(IncrementalUpdate, 'getErrataIds').and.callFake(function() {
            return ['foo', 'bar'];
        });

        expect($scope.errataSearchString(false)).toBe('applicable_errata = "foo" or applicable_errata = "bar"');
        expect($scope.errataSearchString(true)).toBe('installable_errata = "foo" or installable_errata = "bar"');
    });

    it("provides a way to filter on environment", function () {
        var nutupane = $scope.nutupane;

        spyOn(nutupane, 'setParams').and.callThrough();
        spyOn(nutupane, 'refresh');

        $scope.selectEnvironment('foo');

        expect(nutupane.refresh).toHaveBeenCalled();
        expect($scope.environmentFilter).toBe('foo');
    });

    describe("provides a way to go to the next apply step", function () {
        beforeEach(function () {
            spyOn($scope.nutupane, 'getAllSelectedResults').and.callThrough();
            spyOn($scope, 'transitionTo');
        });

        afterEach(function() {
            expect($scope.nutupane.getAllSelectedResults).toHaveBeenCalled();
        });

        it("and goes to the errata details apply page if there is an errata", function () {
            $scope.errata = {id: 1};
            $scope.goToNextStep();
            expect($scope.transitionTo).toHaveBeenCalledWith('erratum.apply', {errataId: $scope.errata.id})
        });

        it("and goes to the errata apply page if there is not an errata", function () {
            $scope.goToNextStep();
            expect($scope.transitionTo).toHaveBeenCalledWith('apply-errata.confirm');
        });
    });
});
