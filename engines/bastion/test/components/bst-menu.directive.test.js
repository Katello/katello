describe('Directive: bstMenu', function() {
    var scope,
        compile,
        window,
        testMenu,
        element,
        elementScope;

    beforeEach(module(
        'Bastion.components',
        'components/views/bst-menu.html',
        'components/views/bst-dropdown.html',
        'components/views/bst-flyout.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_, $window) {
        compile = _$compile_;
        scope = _$rootScope_;
        window = angular.element($window);
    }));

    beforeEach(function() {
        testMenu = {items: [
            {url: 'http://redhat.com', display: 'Red Hat'},
            {url: 'http://google.com', display: 'Google'},
            {display: 'Projects', type: 'dropdown', items: [
                {url: 'http://katello.org', display: 'Katello'},
                {url: 'http://theforeman.org', display: 'Foreman'}
            ]}
        ]};
        scope.items = testMenu;

        element = angular.element('<nav bst-menu="items"></nav>');
        compile(element)(scope);
        scope.$digest();

        elementScope = element.isolateScope();
    });

    it("should display a nav", function() {
        expect(element.is('nav')).toBe(true);
    });

    it("should display a .menu-container <ul>", function() {
        expect(element.find('.menu-container').length).toBe(1);
    });

    it("should display a .menu-item <li> for each top level menu item", function() {
        expect(element.find('.menu-item').length).toBe(3);
    });

    it("should display an <li> element for each item (including children).", function() {
        expect(element.find('li').length).toBe(5);
    });

    describe("should handle mouse events for child dropdowns", function() {
        var target;

        beforeEach(function() {
            target = angular.element(element.find('li')[2]);
            spyOn(elementScope, 'handleHover').and.callThrough();
        });

        it("by setting the item to active on mouse in", function() {
            target.mouseenter();

            expect(elementScope.handleHover).toHaveBeenCalledWith(testMenu.items[2], true);
            expect(testMenu.items[2].active).toBe(true);
            expect(elementScope.dropdown.show).toBe(true);
            expect(elementScope.dropdown).toBe(testMenu.items[2].items);
        });

        it("by setting the item to inactive on mouse out", function() {
            target.mouseenter();
            target.mouseleave();

            expect(elementScope.handleHover).toHaveBeenCalledWith(testMenu.items[2], false);
            expect(elementScope.dropdown.show).toBe(false);
        });
    });
});
