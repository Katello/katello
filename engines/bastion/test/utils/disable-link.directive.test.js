describe('Directive: disableLink', function () {
    var element, $compile, $rootScope, compileDirective;

    compileDirective = function () {
        var html = '<a ng-click="blah()" ui-sref="blah" disable-link="item.disabled">Click Me</a>';
        element = angular.element(html);
        $rootScope.item = {};
        element = $compile(element)($rootScope);
        $rootScope.$digest();
    };

    beforeEach(module('Bastion.utils'));

    beforeEach(inject(function (_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $rootScope = _$rootScope_.$new();
        compileDirective();
    }));

    describe("stops the link from being followed", function () {
        beforeEach(function () {
            compileDirective();
            $rootScope.item.disabled = true;
            $rootScope.$digest();
        });

        it("by preventing the click event", function () {
            var event = {
                type: 'click',
                preventDefault: function () {}
            };

            spyOn(event, 'preventDefault');
            element.trigger(event);
            expect(event.preventDefault).toHaveBeenCalled();
        });
    });
});
