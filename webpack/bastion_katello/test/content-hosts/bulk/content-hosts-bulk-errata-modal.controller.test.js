describe('Controller: ContentHostsBulkErrataModalController', function() {
    var $scope, $controller, controllerParams, $uibModalInstance, hostIds, translate, HostBulkAction, HostCollection, selectedErrata,
         hostIds, CurrentOrganization, Nutupane;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        HostBulkAction = {
            installContent: function() {}
        };
        translate = function() {};
        CurrentOrganization = 'foo';
        selectedErrata = [1, 2, 3, 4]
        hostIds = {included: {ids: [1, 2, 3]}};
        Nutupane = function() {
            this.table = {
                showColumns: function () {},
                getSelected: function () {return selectedErrata}
            };

            this.setParams = function () {}
        };

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        hostIds = {included: {ids: [1, 2, 3]}};
    });

    beforeEach(inject(function(_$controller_, $rootScope, $q, $window) {
        $window.AUTH_TOKEN = 'secret_token';
        $scope = $rootScope.$new();
        $controller = _$controller_;

        $scope.table = {
            rows: [],
            numSelected: 5
        };

        $controller('ContentHostsBulkErrataModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            hostIds: hostIds,
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
            _.extend(hostIds, {
                content_type: 'errata',
                content: [1, 2, 3]
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });
    
    it("provides a function for closing the modal", function () {
        spyOn($uibModalInstance, 'close');
        $scope.ok();
        expect($uibModalInstance.close).toHaveBeenCalled();
    });

    it("provides a function for cancelling the modal", function () {
        spyOn($uibModalInstance, 'dismiss');
        $scope.cancel();
        expect($uibModalInstance.dismiss).toHaveBeenCalled();
    });
});
