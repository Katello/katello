describe('Directive: pathSelector', function() {
    var scope,
        compile,
        paths,
        element,
        elementScope;

    beforeEach(module(
        'Bastion.components',
        'components/views/path-selector.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        paths = [
            [
                {id: 1, name: 'Library'},
                {id: 2, name: 'Dev'},
                {id: 3, name: 'Test'}
            ],[
                {id: 1, name: 'Library'},
                {id: 4, name: 'Stage'}
            ]
        ];
        scope.paths = paths;

        scope.objPaths = [
            {
                environments: [
                    {id: 1, name: 'Library'},
                    {id: 2, name: 'Dev'},
                    {id: 3, name: 'Test'}
                ]
            }
        ];

        scope.environment = {};

        element = angular.element('<div path-selector="paths" ng-model="environment" mode="singleSelect"></div>');
        compile(element)(scope);
        scope.$digest();

        elementScope = element.isolateScope();
    });

    it("should create two seperate paths", function() {
        expect(element.find('.path-list').length).toBe(2);
    });

    it("should have three items in the first path", function() {
        expect(element.find('.path-list:first .path-list-item').length).toBe(3);
    });

    it("should have two items in the second path", function() {
        expect(element.find('.path-list:eq(1) .path-list-item').length).toBe(2);
    });

    it("should select both items if two items with the same id exist", function() {
        var checkbox = element.find('.path-list:first .path-list-item:first').find('input');

        checkbox.trigger('click');
        checkbox.attr('checked', 'checked');
        checkbox.prop('checked', true);

        expect(element.find('.path-list:eq(1)').find('.path-list-item:first input').is(':checked')).toBe(true);
    });

    it("should provide a way to disable path selection", function () {
        element = angular.element('<div path-selector="paths" ng-model="environment" mode="singleSelect" disable-trigger="disableAll"></div>');
        compile(element)(scope);

        scope.disableAll = false;
        scope.$digest();
        expect(element.find('.path-list-item:first input').attr('disabled')).toBe(undefined);

        scope.disableAll = true;
        scope.$digest();
        expect(element.find('.path-list-item:first input').attr('disabled')).toBe('disabled');
    });

    it("should provide a way to use paths that are objects", function() {
        element = angular.element('<div path-selector="objPaths" ng-model="environment" mode="singleSelect" path-attribute="environments"></div>');
        compile(element)(scope);
        scope.$digest();

        expect(element.find('.path-list').length).toBe(1);
        expect(element.find('.path-list:first .path-list-item').length).toBe(3);
    });

    it ("should not unselect by default", function () {
        var checkbox = element.find('.path-list:first .path-list-item:first').find('input');

        expect(checkbox.is(':checked')).toBe(false);

        checkbox.click();
        expect(checkbox.is(':checked')).toBe(true);

        checkbox.click();
        expect(checkbox.is(':checked')).toBe(true);
    });

    it("should provide a way to unselect an environment", function () {
        var checkbox, element;

        element = angular.element('<div path-selector="paths" ng-model="environment" mode="singleSelect" selection-required="false"></div>');
        compile(element)(scope);
        scope.$digest();
        checkbox = element.find('.path-list:first .path-list-item:first').find('input');

        expect(checkbox.is(':checked')).toBe(false);

        checkbox.click();
        expect(checkbox.is(':checked')).toBe(true);

        checkbox.click();
        expect(checkbox.is(':checked')).toBe(false);
    });


});
