describe('Controller: ContentHostsBulkActionErrataController', function() {
    var $scope, $q, translate, HostBulkAction, HostCollection, selectedErrata,
         selectedContentHosts, CurrentOrganization, Nutupane;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        HostBulkAction = {
            installContent: function() {}
        };
        translate = function() {};
        CurrentOrganization = 'foo';
        selectedErrata = [1, 2, 3, 4]
        selectedContentHosts = {included: {ids: [1, 2, 3]}};
        Nutupane = function() {
            this.table = {
                showColumns: function () {},
                getSelected: function () {return selectedErrata}
            };

        };
    });

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();
        $scope.nutupane = {
            table: {
                rows: [{}],
                numSelected: 5
            }
        };
        $scope.nutupane.getAllSelectedResults = function () { return selectedContentHosts }
        $scope.setState = function(){};

        $scope.detailsTable = {
            rows: [],
            numSelected: 5
        };

        $scope.table = {
            rows: [{}],
            numSelected: 5
        };

        $controller('ContentHostsBulkActionErrataController', {$scope: $scope,
            $q: $q,
            HostBulkAction: HostBulkAction,
            HostCollection: HostCollection,
            Nutupane: Nutupane,
            translate: translate,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it("can install errata on multiple content hosts", function () {

        spyOn(HostBulkAction, 'installContent');
        $scope.installErrata();

        expect(HostBulkAction.installContent).toHaveBeenCalledWith(
            _.extend(selectedContentHosts, {
                content_type: 'errata',
                content: [1, 2, 3]
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("Should fetch new errata on initial load if there are initial items present", function () {
        $scope.initialLoad = true;
        spyOn($scope, 'fetchErrata');
        $scope.$apply();
        expect($scope.fetchErrata).toHaveBeenCalled();
    });

    it("watches for table row changes", function () {
        $scope.outOfDate = false;
        $scope.initialLoad = false;
        $scope.table.numSelected = $scope.table.numSelected + 1;
        $scope.$apply();
        expect($scope.outOfDate).toBe(true);
    })

});
