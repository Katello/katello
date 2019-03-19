describe('Directive: bstAlert', function() {
    var $animate, $timeout, scope, compile, element, elementScope;

    function createDirective (providedElement) {
        element = angular.element('<div bst-alert="info"></div>');

        if (providedElement) {
            element = providedElement;
        }

        compile(element)(scope);
        scope.$digest();
        elementScope = element.isolateScope();
    }

    beforeEach(module('Bastion.components', 'components/views/bst-alert.html'));

    beforeEach(module(function ($provide) {
        $animate = {
            addClass: function () {},
            removeClass: function () {},
            cancel: function () {},
            leave: function () {
                return {
                    then: function (callback) {
                        callback();
                    }
                }
            }
        };

        $timeout = function (callback) {
            callback();
        };

        $provide.value('$animate', $animate);
        $provide.value('$timeout', $timeout);
    }));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        createDirective();
    });

    it("should display an alert", function() {
        expect(element.find('.alert').length).toBe(1);
    });

    it("should display a close icon if a close function is provided", function () {
        element = angular.element('<div bst-alert="info" close="close()"></div>');
        createDirective(element);
        expect(elementScope.closeable).toBe(true);
    });

    describe("can start the fade", function () {
        beforeEach(function () {
            spyOn($animate, 'leave').and.callThrough();
            spyOn(elementScope, 'close');
        });

        it("and fades if the fade is not prevented", function () {
            elementScope.fadePrevented = false;
            elementScope.startFade();

            expect($animate.leave).toHaveBeenCalled();
            expect(elementScope.close).toHaveBeenCalled();
        });

        it("but does not fade if the fade is prevented", function () {
            elementScope.fadePrevented = true;
            elementScope.startFade();

            expect($animate.leave).not.toHaveBeenCalled();
            expect(elementScope.close).not.toHaveBeenCalled();
        });
    });

    describe("can cancel the fade", function () {
        beforeEach(function () {
            element = angular.element('<div bst-alert="success"></div>');
            createDirective(element);
        });

        it("by setting fadePrevented", function () {
            elementScope.cancelFade();
            expect(elementScope.fadePrevented).toBe(true);
        });

        it("by calling $animate.cancel() if the animation is in progress", function () {
            spyOn($animate, 'cancel');
            elementScope.cancelFade();
            expect($animate.cancel).toHaveBeenCalled();
        });
    });

    describe("automatically starts the fade", function () {
        beforeEach(function () {
            spyOn($animate, 'leave').and.callThrough();
        });

        it("for success alerts", function () {
            element = angular.element('<div bst-alert="success"></div>');
            createDirective(element);
            expect(elementScope.fadePrevented).toBe(false);
            expect($animate.leave).toHaveBeenCalled();
        });

        it("but not for non-success alerts", function () {
            createDirective();
            expect(elementScope.fadePrevented).toBe(true);
            expect($animate.leave).not.toHaveBeenCalled();
        });
    });
});
