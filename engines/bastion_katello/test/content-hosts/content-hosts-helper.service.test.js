describe('Controller: ContentHostsController', function() {
    var ContentHostsHelper;

    beforeEach(module('Bastion.content-hosts'));

    beforeEach(inject(function($injector) {
        ContentHostsHelper = $injector.get('ContentHostsHelper');
    }));

    it("provides a way to get the status color for the content host.", function() {
        expect(ContentHostsHelper.getSubscriptionStatusColor("valid")).toBe("green");
        expect(ContentHostsHelper.getSubscriptionStatusColor("partial")).toBe("yellow");
        expect(ContentHostsHelper.getSubscriptionStatusColor("error")).toBe("red");
    });

    it("provides a way to get the global status color.", function() {
        expect(ContentHostsHelper.getGlobalStatusColor(0)).toBe("green");
        expect(ContentHostsHelper.getGlobalStatusColor(1)).toBe("yellow");
        expect(ContentHostsHelper.getGlobalStatusColor(2)).toBe("red");
    });

});
