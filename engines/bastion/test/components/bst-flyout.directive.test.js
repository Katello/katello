describe('Directive: bstFlyout', function() {
    var scope,
        compile,
        testItems,
        element,
        elementScope;

    beforeEach(module('Bastion.components', 'components/views/bst-flyout.html'));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        testItems = [
            {url: 'http://redhat.com', display: 'Red Hat'},
            {url: 'http://google.com', display: 'Google'},
        ];
        scope.items = testItems;

        element = angular.element('<ul bst-flyout="items"></ul>');
        compile(element)(scope);
        scope.$digest();

        elementScope = element.isolateScope();
        elementScope.setHover = function() {};
    });

    it("should display a .flyout <ul>", function() {
        expect(element.is('ul')).toBe(true);
        expect(element.hasClass('flyout')).toBe(true);
    });

    it("should display an <li> element for each item.", function() {
        expect(element.find('li').length).toBe(2);
        expect(element.find('.flyout-item').length).toBe(2);
    });

    describe("should respond to mouse events", function() {
        var target;

        beforeEach(function() {
            target = angular.element(element.find('li')[1]);
            spyOn(elementScope, 'setHover');
        });

        it("by setting the item to active on mouse in", function() {
            target.mouseenter();

            expect(elementScope.setHover).toHaveBeenCalledWith(testItems[1], true);
        });

        it("by setting the item to inactive on mouse out", function() {
            target.mouseleave();

            expect(elementScope.setHover).toHaveBeenCalledWith(testItems[1], false);
        });
    });
});
