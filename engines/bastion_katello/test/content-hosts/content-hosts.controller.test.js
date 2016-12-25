describe('Controller: ContentHostsController', function() {
    var $scope, $uibModal, translate, selected, HostBulkAction, Nutupane;

    // load the content hosts module and template
    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    // Set up mocks
    beforeEach(function() {
        selected = {included: {ids: [1, 2, 3]}};

        HostBulkAction = {
            destroyHosts: function() {}
        };

        Nutupane = function () {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.enableSelectAllResults = function () {};
            this.getAllSelectedResults = function () {
                return selected
            };

            this.invalidate = function () {}
        };
        translate = function(message) {
            return message;
        };
        $uibModal = {
            open: function () {}
        }
    });

    // Initialize controller
    beforeEach(inject(function($controller, $rootScope, $state) {
        $scope = $rootScope.$new();

        $controller('ContentHostsController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            HostBulkAction: HostBulkAction,
            Nutupane: Nutupane,
            $uibModal: $uibModal,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it("sets a table on the $scope.", function() {
        expect($scope.table).toBeDefined();
    });

    it("can unregister multiple content hosts", function() {
        spyOn(HostBulkAction, 'destroyHosts');
        $scope.performDestroyHosts();

        expect(HostBulkAction.destroyHosts).toHaveBeenCalledWith(_.extend(selected, {'organization_id': 'foo'}),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can open a bulk host collections modal", function () {
        var result;
        spyOn($uibModal, 'open');

        $scope.openHostCollectionsModal();

        result = $uibModal.open.calls.argsFor(0)[0];

        expect(result.templateUrl).toContain('content-hosts-bulk-host-collections-modal.html');
        expect(result.controller).toBe('ContentHostsBulkHostCollectionsModalController');
    });

    it("can open a bulk packages modal", function () {
        var result;
        spyOn($uibModal, 'open');

        $scope.openPackagesModal();

        result = $uibModal.open.calls.argsFor(0)[0];

        expect(result.templateUrl).toContain('content-hosts-bulk-packages-modal.html');
        expect(result.controller).toBe('ContentHostsBulkPackagesModalController');
    });


    it("can open a bulk errata modal", function () {
        var result;
        spyOn($uibModal, 'open');

        $scope.openErrataModal();

        result = $uibModal.open.calls.argsFor(0)[0];

        expect(result.templateUrl).toContain('content-hosts-bulk-errata-modal.html');
        expect(result.controller).toBe('ContentHostsBulkErrataModalController');
    });

    it("can open a bulk environment modal", function () {
        var result;
        spyOn($uibModal, 'open');

        $scope.openEnvironmentModal();

        result = $uibModal.open.calls.argsFor(0)[0];

        expect(result.templateUrl).toContain('content-hosts-bulk-environment-modal.html');
        expect(result.controller).toBe('ContentHostsBulkEnvironmentModalController');
    });

    it("can open a bulk subscriptions modal", function () {
        var result;
        spyOn($uibModal, 'open');

        $scope.openSubscriptionsModal();

        result = $uibModal.open.calls.argsFor(0)[0];

        expect(result.templateUrl).toContain('content-hosts-bulk-subscriptions-modal.html');
        expect(result.controller).toBe('ContentHostsBulkSubscriptionsModalController');
    });
});
