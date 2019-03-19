describe('Directive: bstDropdown', function() {
    var scope,
        compile,
        testItems,
        element,
        elementScope;

    beforeEach(module(
        'Bastion.components',
        'components/views/bst-dropdown.html',
        'components/views/bst-flyout.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        testItems = [
            {url: 'http://redhat.com', display: 'Red Hat'},
            {url: 'http://google.com', display: 'Google'},
            {display: 'Projects', type: 'flyout', items: [
                {url: 'http://katello.org', display: 'Katello'},
                {url: 'http://theforeman.org', display: 'Foreman'}
            ]}
        ];
        scope.items = testItems;

        element = angular.element('<ul bst-dropdown="items"></ul>');
        compile(element)(scope);
        scope.$digest();

        elementScope = element.isolateScope();
    });

    it("should display a dropdown <ul>", function() {
        expect(element.is('ul')).toBe(true);
        expect(element[0].hasAttribute('uib-dropdown')).toBe(true);
    });

    it("should display a .dropdown-item <li> for each top level menu item", function() {
        expect(element.find('.dropdown-item').length).toBe(3);
    });

    it("should display an <li> element for each item (including flyout children).", function() {
        expect(element.find('li').length).toBe(5);
    });

    describe("should respond to mouse events", function() {
        var target;

        beforeEach(function() {
            target = angular.element(element.find('li')[1]);
            spyOn(elementScope, 'setHover').and.callThrough();
        });

        it("by setting the item to active on mouse in", function() {
            target.mouseenter();

            expect(elementScope.setHover).toHaveBeenCalledWith(testItems[1], true);
            expect(testItems[1].active).toBe(true);
        });

        it("by setting the item to inactive on mouse out", function() {
            target.mouseleave();

            expect(elementScope.setHover).toHaveBeenCalledWith(testItems[1], false);
            expect(testItems[1].active).toBe(false);
        });
    });

    describe("should handle mouse events for child flyouts", function() {
        var target;

        beforeEach(function() {
            target = angular.element(element.find('li')[2]);
            spyOn(elementScope, 'setHover').and.callThrough();
        });

        it("by setting the item to active on mouse in", function() {
            target.mouseenter();

            expect(elementScope.setHover).toHaveBeenCalledWith(testItems[2], true);
            expect(testItems[2].active).toBe(true);
        });

        it("by setting the item to inactive on mouse out", function() {
            target.mouseenter();
            target.mouseleave();

            expect(elementScope.setHover).toHaveBeenCalledWith(testItems[2], false);
        });
    });

    it("provides a way to tell if the direction is right", function() {
        expect(elementScope.isRight('right')).toBe(true);
        expect(elementScope.isRight('left')).toBe(false);
    });
});
