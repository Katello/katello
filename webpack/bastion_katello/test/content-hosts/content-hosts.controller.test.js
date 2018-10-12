describe('Controller: ContentHostsController', function() {
    var $scope, $uibModal, translate, selected, HostBulkAction, ContentHostsModalHelper, Nutupane;

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
        };
        ContentHostsModalHelper ={
            resolveFunc: function(){return selected;},
            openHostCollectionsModal : function () {},
            openPackagesModal :function () {},
            openErrataModal : function () {},
            openEnvironmentModal : function () {},
            openSubscriptionsModal : function (){}
        };
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
            ContentHostsModalHelper:ContentHostsModalHelper,
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

});
