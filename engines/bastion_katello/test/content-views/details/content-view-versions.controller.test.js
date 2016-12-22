describe('Controller: ContentViewVersionsController', function() {
    var $scope

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            translate = function (string) {
                return string;
            };

        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: 1});
        $scope.reloadVersions = function () {};
        $scope.taskTypes = {
            promotion: "promotion",
            publish: "publish"
        };


        spyOn($scope, 'reloadVersions');

        $controller('ContentViewVersionsController', {
            $scope: $scope,
            translate: translate
        });
    }));

    it("puts an empty table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("defines a method for deloading the versions", function() {
        expect($scope.reloadVersions).toBeDefined();
    });

    it("correctly hide a version's progress", function() {
        var version = {active_history: [], task: {state: 'running', progressbar: {type: 'success'}}};
        expect($scope.hideProgress(version)).toBe(true);

        version = {active_history: [{}], task: {state: 'running', progressbar: {type: 'success'}}};
        expect($scope.hideProgress(version)).toBe(false);

        version = {active_history: [], task: {state: 'stopped', progressbar: {type: 'success'}}};
        expect($scope.hideProgress(version)).toBe(true);

        version = {active_history: [{}], task: {state: 'stopped', progressbar: {type: 'error'}}};
        expect($scope.hideProgress(version)).toBe(false);
    });

    it("correctly returns task in progress", function() {
        var version = {};
        expect($scope.taskInProgress(version)).toBe(false);

        version = {task: {state: 'running'}};
        expect($scope.taskInProgress(version)).toBe(true);

        version = {task: {state: 'pending'}};
        expect($scope.taskInProgress(version)).toBe(true);

        version = {task: {state: 'error'}};
        expect($scope.taskInProgress(version)).toBe(false);

        version = {task: {state: 'stopped'}};
        expect($scope.taskInProgress(version)).toBe(false);
    });

    it("correctly returns task failed", function() {
        var version = {};
        expect($scope.taskFailed(version)).toBe(false);

        version = {task: {result: 'success'}};
        expect($scope.taskFailed(version)).toBe(false);

        version = {task: {result: 'pending'}};
        expect($scope.taskFailed(version)).toBe(false);

        version = {task: {result: 'warning'}};
        expect($scope.taskFailed(version)).toBe(false);

        version = {task: {result: 'error'}};
        expect($scope.taskFailed(version)).toBe(true);
    });

    it("determines what history text to display", function() {
        var version = {active_history: [],
            last_event: {environment: {name: 'test'},
                         task: {label: $scope.taskTypes.promotion}
        }};
        expect($scope.historyText(version)).toBe("Promoted to test");

        version.last_event.task.label = $scope.taskTypes.publish;
        expect($scope.historyText(version)).toBe("Published");
    });
});
