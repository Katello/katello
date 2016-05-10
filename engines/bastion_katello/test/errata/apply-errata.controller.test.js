describe('Controller: ApplyErrataController', function() {
    var $controller, dependencies, $scope, translate, HostBulkAction, ContentViewVersion,
        CurrentOrganization;

    beforeEach(module('Bastion.errata', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        $controller = $injector.get('$controller'),

        translate = function (string) {
            return string;
        };

        HostBulkAction = {
            failed: false,
            installContent: function (params, success, error) {
                if (this.failed) {
                    error({data: {errors: ['error']}});
                } else {
                    success({id: 1});
                }
            },
            availableIncrementalUpdates: function () {}
        };

        ContentViewVersion = {
            incrementalUpdate: function (params, success, error) {
                if (this.failed) {
                    error({data: {errors: ['error']}});
                } else {
                    success({id: 1});
                }
            }
        };

        CurrentOrganization = 'foo';

        $scope = $injector.get('$rootScope').$new();
        $scope.checkIfIncrementalUpdateRunning = function () {};
        $scope.errorMessages = [];
        $scope.successMessages = [];

        dependencies = {
            $scope: $scope,
            translate: translate,
            HostBulkAction: HostBulkAction,
            ContentViewVersion: ContentViewVersion,
            CurrentOrganization: CurrentOrganization
        };
    }));

    describe("sets the errataIds on the scope", function () {
        it("to the errataId in the $stateParams if present", function () {
            $scope.$stateParams = {errataId: 2};
            $controller('ApplyErrataController', dependencies);
            expect($scope.errataIds).toEqual([2]);
        });

        it("to the selected errata from the errata table otherwise", function () {
            $scope.selectedErrata = {included: {ids: [1]}};
            $controller('ApplyErrataController', dependencies);
            expect($scope.errataIds).toEqual([1]);
        });
    });

    it("sets the updates on the $scope if there are selected content hosts", function () {
        var updates = ['update'];
        spyOn(HostBulkAction, 'availableIncrementalUpdates').andCallFake(function (params, success) {
            success(updates);
        });

        $scope.$stateParams = {errataId: 2};
        $scope.selectedContentHosts = ['abc'];

        $controller('ApplyErrataController', dependencies);

        expect(HostBulkAction.availableIncrementalUpdates).toHaveBeenCalledWith($scope.selectedContentHosts,
            jasmine.any(Function));
        expect($scope.updates).toEqual(updates);
    });

    describe("can apply errata", function () {
        var expectedParams;

        beforeEach(function () {
            $controller('ApplyErrataController', dependencies);
            $scope.selectedContentHosts = {include: [1, 2, 3]};
            $scope.errataIds = [10];
        });

        describe("if no incremental update is needed", function () {
            beforeEach(function () {
                expectedParams = {
                    include: [1, 2, 3],
                    'content_type': 'errata',
                    content: [10],
                    'organization_id': CurrentOrganization
                };

                $scope.updates = [];
                spyOn(HostBulkAction, 'installContent').andCallThrough();
            });

            afterEach(function () {
                expect(HostBulkAction.installContent).toHaveBeenCalledWith(expectedParams, jasmine.any(Function),
                    jasmine.any(Function));
            });

            it("and succeed", function () {
                spyOn($scope, 'transitionTo');
                $scope.confirmApply();

                expect($scope.transitionTo).toHaveBeenCalledWith('errata.tasks.details', {taskId: 1});
                expect($scope.errorMessages.length).toBe(0);
            });

            it("and fail", function () {
                HostBulkAction.failed = true;
                $scope.confirmApply();

                expect($scope.successMessages.length).toBe(0);
                expect($scope.errorMessages.length).toBe(1);
                expect($scope.errorMessages[0]).toBe('error');
            });
        });

        describe("if an incremental update is needed", function () {
            beforeEach(function () {
                expectedParams = {
                    'add_content': {
                        'errata_ids': [10]
                    },
                    'content_view_version_environments': [{
                        'content_view_version_id': 1,
                        'environment_ids': [2]
                    }],
                    'resolve_dependencies': true
                };

                $scope.updates = [{
                    'content_view_version': {id: 1},
                    environments: [{id: 2}]
                }];

                spyOn(ContentViewVersion, 'incrementalUpdate').andCallThrough();
            });

            afterEach(function () {
                expect(ContentViewVersion.incrementalUpdate).toHaveBeenCalledWith(expectedParams, jasmine.any(Function),
                    jasmine.any(Function));
            });

            it("and succeed", function () {
                spyOn($scope, 'transitionTo');

                $scope.confirmApply();

                expect($scope.transitionTo).toHaveBeenCalledWith('errata.tasks.details', {taskId: 1});
                expect($scope.errorMessages.length).toBe(0);
                expect($scope.hasComposites($scope.updates)).toBeFalsy();
            });

            it("and fail", function () {
                ContentViewVersion.failed = true;
                $scope.confirmApply();

                expect($scope.successMessages.length).toBe(0);
                expect($scope.errorMessages.length).toBe(1);
                expect($scope.errorMessages[0]).toBe('error');
            });

            it("can pass a parameter to update the content hosts", function () {
                expectedParams['update_hosts'] = {include: [1, 2, 3]};
                $scope.applyErrata = true;

                $scope.confirmApply();
            });
        });

        describe("if an incremental update is needed with composites", function () {
            beforeEach(function () {
                expectedParams = {
                    'add_content': {
                        'errata_ids': [10]
                    },
                    'content_view_version_environments': [{
                        'content_view_version_id': 1,
                        'environment_ids': [2]
                    },{
                        'content_view_version_id': 5,
                        'environment_ids': []
                    }],
                    'resolve_dependencies': true
                };

                $scope.updates = [{
                    'content_view_version': {id: 1},
                    environments: [{id: 2}],
                    components: [{id: 5}]
                }];

                spyOn(ContentViewVersion, 'incrementalUpdate').andCallThrough();
            });

            afterEach(function () {
                expect(ContentViewVersion.incrementalUpdate).toHaveBeenCalledWith(jasmine.any(Object), jasmine.any(Function),
                    jasmine.any(Function));
                expect(ContentViewVersion.incrementalUpdate.mostRecentCall.args[0]['add_content']).toEqual(expectedParams['add_content'])
                expect(ContentViewVersion.incrementalUpdate.mostRecentCall.args[0]['content_view_version_environments']).toContain(expectedParams['content_view_version_environments'][0])
                expect(ContentViewVersion.incrementalUpdate.mostRecentCall.args[0]['content_view_version_environments']).toContain(expectedParams['content_view_version_environments'][1])
                expect(ContentViewVersion.incrementalUpdate.mostRecentCall.args[0]['resolve_dependencies']).toEqual(expectedParams['resolve_dependencies'])
            });

            it("and succeed", function () {
                spyOn($scope, 'transitionTo');

                $scope.confirmApply();

                expect($scope.transitionTo).toHaveBeenCalledWith('errata.tasks.details', {taskId: 1});
                expect($scope.errorMessages.length).toBe(0);
                expect($scope.hasComposites($scope.updates)).toBeTruthy();
            });
        });

        describe("if an incremental update is needed with composites and component", function () {
            beforeEach(function () {
                expectedParams = {
                    'add_content': {
                        'errata_ids': [10]
                    },
                    'content_view_version_environments': [{
                        'content_view_version_id': 1,
                        'environment_ids': [2]
                    },{
                        'content_view_version_id': 5,
                        'environment_ids': [99]
                    }],
                    'resolve_dependencies': true
                };

                $scope.updates = [{
                    'content_view_version': {id: 1},
                    environments: [{id: 2}],
                    components: [{id: 5}]
                },{
                    'content_view_version': {id: 5},
                    environments: [{id: 99}],
                    components: undefined
                }];

                spyOn(ContentViewVersion, 'incrementalUpdate').andCallThrough();
            });

            afterEach(function () {
                expect(ContentViewVersion.incrementalUpdate).toHaveBeenCalledWith(jasmine.any(Object), jasmine.any(Function),
                    jasmine.any(Function));
                expect(ContentViewVersion.incrementalUpdate.mostRecentCall.args[0]['add_content']).toEqual(expectedParams['add_content'])
                expect(ContentViewVersion.incrementalUpdate.mostRecentCall.args[0]['content_view_version_environments']).toContain(expectedParams['content_view_version_environments'][0])
                expect(ContentViewVersion.incrementalUpdate.mostRecentCall.args[0]['content_view_version_environments']).toContain(expectedParams['content_view_version_environments'][1])
                expect(ContentViewVersion.incrementalUpdate.mostRecentCall.args[0]['resolve_dependencies']).toEqual(expectedParams['resolve_dependencies'])
            });

            it("and succeed", function () {
                spyOn($scope, 'transitionTo');

                $scope.confirmApply();

                expect($scope.transitionTo).toHaveBeenCalledWith('errata.tasks.details', {taskId: 1});
                expect($scope.errorMessages.length).toBe(0);
                expect($scope.hasComposites($scope.updates)).toBeTruthy();
            });
        });
    });
});
