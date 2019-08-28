describe('Controller: FilterRuleMatchingPackageModal', function() {
  var $scope, $uibModalInstance, filterRuleId, Package, Nutupane, rule;

  beforeEach(module('Bastion.content-views'));

  beforeEach(function() {
      $uibModalInstance = {
          close: function () {},
          dismiss: function () {}
      };
      filterRuleId = 1;
      Package = {}
      Nutupane = function() {
        this.table = {};
        this.setSearchKey = function () {}
        this.setTableName = function () {}
      }
      CurrentOrganization = 1;
  });

  beforeEach(inject(function(_Notification_, $controller, $rootScope, _$q_) {
      $scope = $rootScope.$new();
      $controller('FilterRuleMatchingPackageModal', {
          $scope: $scope,
          $uibModalInstance: $uibModalInstance,
          filterRuleId: filterRuleId,
          Package: Package,
          Nutupane: Nutupane,
          CurrentOrganization: CurrentOrganization
      });
  }));

  it("provides a function for closing the modal", function () {
      spyOn($uibModalInstance, 'close');
      $scope.cancel();
      expect($uibModalInstance.close).toHaveBeenCalled();
  });

  it("puts a table object on the $scope", function() {
    expect($scope.table).toBeDefined();
  });
});