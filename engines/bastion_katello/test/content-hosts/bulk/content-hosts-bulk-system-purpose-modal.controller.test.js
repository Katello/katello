
describe('Controller: ContentHostsBulkSystemPurposeModalController', function() {
    var $scope, $uibModalInstance, BulkAction, Organization, CurrentOrganization, hostIds;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        BulkAction = {
            systemPurpose: function() {}
        };
        $httpBackend = $injector.get('$httpBackend');

        CurrentOrganization = '1';
        hostIds = {included: {ids: [1, 2]}};

        mockOrg = {
            id: '1',
            service_levels: ['Premium'],
            system_purposes: {
              roles: ['custom-role'],
              usage: ['custom-usage']
            }
          }
  
          Organization = $injector.get('Organization');
          spyOn(Organization, 'get').and.callThrough();
          $httpBackend.expectGET('katello/api/v2/organizations/1').respond(mockOrg);

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        hostIds = {included: {ids: [1, 2]}};
    }));

    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();

        $controller('ContentHostsBulkSystemPurposeModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            hostIds: hostIds,
            HostBulkAction: BulkAction,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it("checks options to show correctly", function() {
        var serviceLevels = $scope.defaultServiceLevels;
        var usageRoles = $scope.defaultRoles;
        var usages = $scope.defaultUsages;
        $httpBackend.flush();

        expect(serviceLevels.length).toEqual(5);
        expect(serviceLevels.sort()).toEqual(['No change', 'None (Clear)', 'Self-Support', 'Standard', 'Premium'].sort());
        expect(usageRoles.length).toEqual(5);
        expect(usageRoles.sort()).toEqual(['No change', 'None (Clear)', 'Red Hat Enterprise Linux Server', 'Red Hat Enterprise Linux Workstation', 'Red Hat Enterprise Linux Compute Node'].sort());
        expect(usages.length).toEqual(5);
        expect(usages.sort()).toEqual(['No change', 'None (Clear)', 'Production', 'Development/Test', 'Disaster Recovery'].sort());
    });

    it("should perform the function and transition", function() {
        var params = _.extend(hostIds, {purpose_usage: null, purpose_role: null, service_level: null});
        spyOn(BulkAction, 'systemPurpose');

        $scope.performAction();
        spyOn($scope, "transitionTo");
        expect(BulkAction.systemPurpose).toHaveBeenCalledWith(params, jasmine.any(Function), jasmine.any(Function));
    });

    it("should return null when 'No Change' is selected", function() {
        var param = $scope.selectedItemToParam(['No change']);
        expect(param).toEqual(null);
    });

    it("should return empty string/array when 'None (Clear)' is only selected", function() {
        var stringParam = $scope.selectedItemToParam('None (Clear)');
        expect(stringParam).toEqual("");
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
