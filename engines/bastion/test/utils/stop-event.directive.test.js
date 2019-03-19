describe('Directive: stopEvent', function () {
    var element;

    beforeEach(module('Bastion.utils'));

    beforeEach(inject(function ($compile, $rootScope) {
        element = angular.element('<input type="text" stop-event="click"/>');
        $compile(element)($rootScope);
        $rootScope.$digest();
    }));

    it("stops propagation on the specified event", function () {
        var event = {
            type: 'click',
            stopPropagation: function () {}
        };

        spyOn(event, 'stopPropagation');
        element.trigger(event);
        expect(event.stopPropagation).toHaveBeenCalled();
    });
});
