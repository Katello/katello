describe('Controller: ContentHostController', function(){
    var $uibModal, selected, resolveFunc, ContentHostsModalHelper;
    mockuibModal ={};
    // load the content hosts module and template
    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    // Set up mocks
    beforeEach(function() {
        // angular.mock.inject(function($uibModal){
        //     uibModal = $uibModal;
        // });
        $uibModal = {
            open: function () {}
        };
        selected = {included: {ids: [1, 2, 3]}};

        resolveFunc = function () {
            return selected;
        };

        module(function($provide) {
            $provide.value('$uibModal', $uibModal);
            return;
        });


    });

    //Set up dependencies
    beforeEach(inject(function($injector) {
       // $uibModal = $injector.get('_$uibModal_');
        ContentHostsModalHelper = $injector.get('ContentHostsModalHelper');
        ContentHostsModalHelper.resolveFunc = resolveFunc;
    }));
    
    it("injects the service properly.", function() {
        expect(ContentHostsModalHelper).toBeDefined();

    });

    it("can open a bulk host collections modal", function() {

        var result;
        spyOn($uibModal, 'open');
        ContentHostsModalHelper.openHostCollectionsModal();
        result = $uibModal.open.calls.argsFor(0)[0];
        expect(result.templateUrl).toContain('content-hosts-bulk-host-collections-modal.html');
        expect(result.controller).toBe('ContentHostsBulkHostCollectionsModalController');
    });

    it("can open a bulk package modal", function() {

        var result;
        spyOn($uibModal, 'open');
        ContentHostsModalHelper.openPackagesModal();
        result = $uibModal.open.calls.argsFor(0)[0];
        expect(result.templateUrl).toContain('content-hosts-bulk-packages-modal.html');
        expect(result.controller).toBe('ContentHostsBulkPackagesModalController');
    });

    it("can open a bulk errata modal", function() {

        var result;
        spyOn($uibModal, 'open');
        ContentHostsModalHelper.openErrataModal();
        result = $uibModal.open.calls.argsFor(0)[0];
        expect(result.templateUrl).toContain('content-hosts-bulk-errata-modal.html');
        expect(result.controller).toBe('ContentHostsBulkErrataModalController');
    });

    it("can open a bulk environment modal", function() {

        var result;
        spyOn($uibModal, 'open');
        ContentHostsModalHelper.openEnvironmentModal();
        result = $uibModal.open.calls.argsFor(0)[0];
        expect(result.templateUrl).toContain('content-hosts-bulk-environment-modal.html');
        expect(result.controller).toBe('ContentHostsBulkEnvironmentModalController');
    });

    it("can open a bulk subscriptions modal", function() {

        var result;
        spyOn($uibModal, 'open');
        ContentHostsModalHelper.openSubscriptionsModal();
        result = $uibModal.open.calls.argsFor(0)[0];
        expect(result.templateUrl).toContain('content-hosts-bulk-subscriptions-modal.html');
        expect(result.controller).toBe('ContentHostsBulkSubscriptionsModalController');
    });

});
