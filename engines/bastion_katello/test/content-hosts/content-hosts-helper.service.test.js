describe('Controller: ContentHostsController', function() {
    var ContentHostsHelper;

    beforeEach(module('Bastion.content-hosts'));

    beforeEach(inject(function($injector) {
        ContentHostsHelper = $injector.get('ContentHostsHelper');
    }));

    it("provides a way to get the status color for the content host.", function() {
        expect(ContentHostsHelper.getStatusColor("valid")).toBe("green");
        expect(ContentHostsHelper.getStatusColor("partial")).toBe("yellow");
        expect(ContentHostsHelper.getStatusColor("error")).toBe("red");
    });

    it("provides a way to get the status color for the provisioning host.", function() {
        expect(ContentHostsHelper.getProvisioningStatusColor("Pending Installation")).toBe("light-blue");
        expect(ContentHostsHelper.getProvisioningStatusColor("Alerts disabled")).toBe("gray");
        expect(ContentHostsHelper.getProvisioningStatusColor("No reports")).toBe("gray");
        expect(ContentHostsHelper.getProvisioningStatusColor("Out of sync")).toBe("orange");
        expect(ContentHostsHelper.getProvisioningStatusColor("Error")).toBe("red");
        expect(ContentHostsHelper.getProvisioningStatusColor("Active")).toBe("light-blue");
        expect(ContentHostsHelper.getProvisioningStatusColor("Pending")).toBe("orange");
    });

});
