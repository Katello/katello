describe('Controller: ContentViewAvailableDockerRepositoriesController', function() {
    var $scope;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'Bastion.i18n'));

    beforeEach(inject(function($injector) {
        var Nutupane,
            $controller = $injector.get('$controller'),
            ContentViewRepositoriesUtil = $injector.get('ContentViewRepositoriesUtil'),
            Repository = $injector.get('MockResource').$new(),
            ContentView = $injector.get('MockResource').$new();

        Nutupane = function () {
            this.getAllSelectedResults = function () {
                return {included: {ids: [1, 2]}};
            };
            this.load = function () {};
            this.table = {};
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: 1});
        $scope.contentView['repository_ids'] = [];
        $scope.save = function () {
            return {
                then: function () {}
            };
        };

        spyOn($scope, 'save').and.callThrough();

        $controller('ContentViewAvailableRepositoriesController', {
            $scope: $scope,
            Repository: Repository,
            Nutupane: Nutupane,
            CurrentOrganization: 'ACME_Corporation',
            ContentViewRepositoriesUtil: ContentViewRepositoriesUtil
        });
    }));

    it("puts a repositories table on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it('provides a method to add repositories to a content view', function() {
        $scope.filteredItems = [{id: 1}];
        $scope.addRepositories($scope.contentView);

        expect($scope.save).toHaveBeenCalled();
        expect($scope.contentView['repository_ids'].length).toBe(1);
    });

});
