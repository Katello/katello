/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

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
