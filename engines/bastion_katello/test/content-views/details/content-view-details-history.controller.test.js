describe('Controller: ContentViewHistoryController', function() {
    var $scope, history, Nutupane;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            translate = function(text) {return text};

        history = [];
        ContentView.history = function(options, callback) {  callback(history) };
        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: 1});

        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };

        spyOn($scope, 'transitionTo');

        $controller('ContentViewHistoryController', {
            $scope: $scope,
            ContentView: ContentView,
            Nutupane: Nutupane,
            translate: translate
        });
    }));

    it('defines details table', function() {
        expect($scope.table).not.toBe(undefined);
    });

});
