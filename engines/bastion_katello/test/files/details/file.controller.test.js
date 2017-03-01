describe('Controller: FileController', function() {
    var $scope,
        File;

    beforeEach(module('Bastion.files', 'Bastion.test-mocks'));

    beforeEach(inject(function($controller, $rootScope, MockResource) {
        $scope = $rootScope.$new();
        File = MockResource.$new();

        $scope.$stateParams = {
            fileId: 1
        };

        $controller('FileController', {
            $scope: $scope,
            File: File
        });
    }));

    it('attaches file to scope', function() {
        expect($scope.file).toBeDefined();
        expect($scope.panel.loading).toBe(false);
    });
});
