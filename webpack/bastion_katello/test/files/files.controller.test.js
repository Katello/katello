describe('Controller: FilesController', function() {
    var $scope,
        File,
        Nutupane;

    beforeEach(module('Bastion.files', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                params: {},
                showColumns: function() {}
            };
        };
    });

    beforeEach(inject(function($controller, $rootScope, MockResource) {
        $scope = $rootScope.$new();

        $controller('FilesController', {
            $scope: $scope,
            Nutupane: Nutupane,
            File: File,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });
});
