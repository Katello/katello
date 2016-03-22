describe('Controller: ContentHostsController', function() {
    var $scope, translate, ContentHost, Nutupane;

    // load the content hosts module and template
    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    // Set up mocks
    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.removeRow = function() {};
            this.get = function() {};
            this.enableSelectAllResults = function() {}
        };
        translate = function(message) {
            return message;
        };
    });

    // Initialize controller
    beforeEach(inject(function($controller, $rootScope, $state) {
        $scope = $rootScope.$new();

        $controller('ContentHostsController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            Nutupane: Nutupane,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it("provides a way to close the details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.contentHostTable.closeItem();
        expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.index');
    });
});
