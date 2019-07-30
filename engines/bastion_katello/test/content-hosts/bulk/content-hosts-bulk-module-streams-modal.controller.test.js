describe('Controller: ContentHostsBulkModuleStreamsModalController', function() {
    var $scope, $controller, $uibModalInstance, hostIds, translate, ModuleStream,
        HostBulkAction,  CurrentOrganization, Nutupane, formValues;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        HostBulkAction = {
            installContent: function() {}
        };
        translate = function() {};
        CurrentOrganization = 'foo';
        selectedModuleStreams = [1, 2, 3, 4];
        Nutupane = function() {
            this.table = {
                showColumns: function () {},
                getSelected: function () {return selectedModuleStreams }
            };

            this.setParams = function () {}
        };

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        hostIds = {included: {ids: [1, 2, 3]}};
        ModuleStream = {};
        ModuleStreamAction = {};
    });

    beforeEach(inject(function(_$controller_, $rootScope, $q, $window) {
        $window.AUTH_TOKEN = 'secret_token';
        $scope = $rootScope.$new();
        $controller = _$controller_;

        $scope.table = {
            rows: [],
            numSelected: 5
        };

        $controller('ContentHostsBulkModuleStreamsModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            ModuleStream: ModuleStream,
            hostIds: hostIds,
            Nutupane: Nutupane,
            translate: translate,
            CurrentOrganization: CurrentOrganization,
            ModuleStreamAction: ModuleStreamAction
        });
    }));

    it("provides a function for cancelling the modal", function () {
        spyOn($uibModalInstance, 'dismiss');
        $scope.cancel();
        expect($uibModalInstance.dismiss).toHaveBeenCalled();
    });

    it("can call module stream actions on multiple content hosts", function() { 
        formValues = {
            authenticityToken: 'secret_token', 
            remoteAction: 'module_stream_action', 
            hostIds: '1,2,3', 
            moduleSpec: 'django:1.9', 
            moduleStreamAction: 'enable'
        };
        $scope.performViaRemoteExecution("django:1.9", "enable");;
        expect($scope.moduleStreamActionFormValues).toEqual(formValues);
    });
});
