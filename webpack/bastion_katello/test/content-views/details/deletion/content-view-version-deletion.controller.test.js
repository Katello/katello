describe('ContentViewVersionDeletionController', function() {
    var $scope, ContentViewVersion, ContentView, $state;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        ContentViewVersion =  $injector.get('MockResource').$new();
        ContentView =  $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {contentViewId: 1, versionId: 1};
        $scope.contentView = ContentView.get({id: $scope.$stateParams.contentViewId});
        $state = {
            current: {name: ""}
        };

        $controller('ContentViewVersionDeletionController', {
            $scope: $scope,
            $state: $state,
            ContentViewVersion: ContentViewVersion,
            ContentView: ContentView,
            translate: function(){}
        });
    }));

    it("should fetch a content view version", function () {
        expect($scope.version).not.toBe(undefined);
    });

    it("should set deletion options", function () {
        expect($scope.deleteOptions).not.toBe(undefined);
    });

    it("should proceed to content hosts pane if needed", function () {
        spyOn($scope, 'needHosts').and.returnValue(true);
        spyOn($scope, 'transitionTo');

        $scope.transitionToNext($scope.stepStates.environments);

        expect($scope.transitionTo).toHaveBeenCalledWith("content-view.version-deletion.content-hosts",
            {contentViewId: $scope.$stateParams.contentViewId, versionId: $scope.$stateParams.versionId});
    });

    it("should read current state if no state passed in", function () {
        spyOn($scope, 'needHosts').and.returnValue(true);
        spyOn($scope, 'transitionTo');

        $state.current.name = $scope.stepStates.environments;
        $scope.transitionToNext();

        expect($scope.transitionTo).toHaveBeenCalledWith("content-view.version-deletion.content-hosts",
            {contentViewId: $scope.$stateParams.contentViewId, versionId: $scope.$stateParams.versionId});
    });

    it("should proceed to activation keys pane if needed", function () {
        spyOn($scope, 'needHosts').and.returnValue(false);
        spyOn($scope, 'needActivationKeys').and.returnValue(true);
        spyOn($scope, 'transitionTo');

        $scope.transitionToNext($scope.stepStates.contentHosts);

        expect($scope.transitionTo).toHaveBeenCalledWith("content-view.version-deletion.activation-keys",
                {contentViewId: $scope.$stateParams.contentViewId, versionId: $scope.$stateParams.versionId});
    });

    it("should go back to cotnent hosts pane if needed", function () {
        spyOn($scope, 'needHosts').and.returnValue(true);
        spyOn($scope, 'transitionTo');

        $scope.transitionBack($scope.stepStates.activationKeys);

        expect($scope.transitionTo).toHaveBeenCalledWith("content-view.version-deletion.content-hosts",
            {contentViewId: $scope.$stateParams.contentViewId, versionId: $scope.$stateParams.versionId});
    });

    it("should go back to environments pane if needed", function () {
        spyOn($scope, 'needHosts').and.returnValue(false);
        spyOn($scope, 'needActivationKeys').and.returnValue(false);
        spyOn($scope, 'transitionTo');

        $scope.transitionBack($scope.stepStates.activationKeys);

        expect($scope.transitionTo).toHaveBeenCalledWith("content-view.version-deletion.environments",
            {contentViewId: $scope.$stateParams.contentViewId, versionId: $scope.$stateParams.versionId});
    });

    it('should detect invalid environments and transition if needed', function () {
        $scope.deleteOptions.environments = [];
        $scope.deleteOptions.deleteArchive = false;
        spyOn($scope, 'transitionTo');

        $scope.validateEnvironmentSelection();
        expect($scope.transitionTo).toHaveBeenCalledWith("content-view.version-deletion.environments",
                {contentViewId: $scope.$stateParams.contentViewId, versionId: $scope.$stateParams.versionId});
    });

    it('should not transition back to start if valid environment set', function () {
        $scope.deleteOptions.environments = [{id: 1}];
        $scope.deleteOptions.deleteArchive = false;
        spyOn($scope, 'transitionTo');

        $scope.validateEnvironmentSelection();
        expect($scope.transitionTo).not.toHaveBeenCalled();
    });

    it('should not transition back to start if valid environment set', function () {
        $scope.deleteOptions.environments = [];
        $scope.deleteOptions.deleteArchive = true;
        spyOn($scope, 'transitionTo');

        $scope.validateEnvironmentSelection();
        expect($scope.transitionTo).not.toHaveBeenCalled();
    });

    it('should properly detect is content hosts are not needed when no content hosts', function () {
        $scope.deleteOptions.environments = [];
        expect($scope.needHosts()).toBe(false);
    });

    it('should properly detect when i need content hosts', function () {
        $scope.deleteOptions.environments = [{host_count: 5}, {host_count: 3}];
        expect($scope.needHosts()).toBe(true);
    });

    it('should calculate total content hosts count properly', function () {
        $scope.deleteOptions.environments = [{host_count: 5}, {host_count: 3}];
        expect($scope.totalHostCount()).toBe(8);
    });

    it('should calculate total activation key count properly', function () {
        $scope.deleteOptions.environments = [{activation_key_count: 5}, {activation_key_count: 3}];
        expect($scope.totalActivationKeyCount()).toBe(8);
    });

    it('should properly detect is keys are not needed when no keys', function () {
        $scope.deleteOptions.environments = [];
        expect($scope.needActivationKeys()).toBe(false);
    });

    it('should properly detect when i need keys', function () {
        $scope.deleteOptions.environments = [{activation_key_count: 5}, {activation_key_count: 3}];
        expect($scope.needActivationKeys()).toBe(true);
    });

    it('should properly detect for environment changes on undefined', function () {
        $scope.selectedEnvironment = {};
        $scope.contentViewsForEnvironment = ['foo'];
        $scope.initEnvironmentWatch($scope);
        $scope.selectedEnvironment = undefined;
        $scope.$apply();
        expect($scope.contentViewsForEnvironment.length).toBe(0);
    });

    it('should properly get content view list when environment is selected to be deleted', function () {
        var contentViewId = 99,
            otherContentViewId = 22,
            environmentId = 88;

        $scope.deleteOptions.environments = [{id: environmentId}]; //user selected env 88 for deletion
        $scope.version = {id: 44, content_view_id: contentViewId}; //user selected version 99 for deletion
        $scope.contentViewsForEnvironment = undefined;
        ContentView.queryUnpaged = function (options, callback) {
          //return 2 content views, once should be ignored
          callback({results: [{id: contentViewId}, {id: otherContentViewId}]});
        };

        spyOn(ContentView, 'queryUnpaged').and.callThrough();

        $scope.selectedEnvironment = undefined;
        $scope.initEnvironmentWatch($scope);
        $scope.selectedEnvironment = {id: environmentId};
        $scope.$apply();

        expect(ContentView.queryUnpaged).toHaveBeenCalledWith({ 'environment_id': environmentId}, jasmine.any(Function));
        expect($scope.contentViewsForEnvironment.length).toBe(1);
        expect($scope.contentViewsForEnvironment[0].id).toBe(otherContentViewId);
    });

    it('should properly get content view list when environment is selected will not be deleted', function () {
        var contentViewId = 99,
            otherContentViewId = 22,
            environmentId = 88,
            otherEnvironmentId = 77;

        $scope.deleteOptions.environments = [{id: otherEnvironmentId}]; //user selected env 88 for deletion
        $scope.version = {id: 44, content_view_id: contentViewId}; //user selected version 99 for deletion
        // $scope.contentViewsForEnvironment = undefined;
        ContentView.queryUnpaged = function (options, callback) {
          //return 2 content views, once should be ignored
          callback({results: [{id: contentViewId}, {id: otherContentViewId}]});
        };

        spyOn(ContentView, 'queryUnpaged').and.callThrough();

        $scope.selectedEnvironment = undefined;
        $scope.initEnvironmentWatch($scope);
        $scope.selectedEnvironment = {id: environmentId};
        $scope.$apply();

        expect(ContentView.queryUnpaged).toHaveBeenCalledWith({ 'environment_id': environmentId}, jasmine.any(Function));
        expect($scope.contentViewsForEnvironment.length).toBe(2);
    });
});
