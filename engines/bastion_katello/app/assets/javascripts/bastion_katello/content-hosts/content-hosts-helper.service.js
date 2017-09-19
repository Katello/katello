/**
 * @ngdoc service
 * @name  Bastion.content-hosts.service:ContentHostsHelper
 *
 * @description
 *   Helper service that contains functionality common amongst content hosts.
 */
angular.module('Bastion.content-hosts').service('ContentHostsHelper',
    function () {
        this.convertMemToGB = function (memoryValue) {
            if (angular.isString(memoryValue)) {
                memoryValue = memoryValue.toLowerCase();
                if (_.includes(memoryValue, "gb")) {
                    memoryValue = memoryValue.replace("gb", "").trim();
                    return memoryValue;
                }
                memoryValue = parseInt(memoryValue);
            }
            memoryValue = (memoryValue / 1048576).toFixed(2);
            return memoryValue;
        };

        this.getHostStatusIcon = function (globalStatus) {
            var icons;
            var colors = {
                // we can remove 'valid', 'partial', and 'invalid' when http://projects.theforeman.org/issues/15347 is fixed
                'valid': 'green',
                'partial': 'yellow',
                'invalid': 'red',
                0: 'green',
                1: 'yellow',
                2: 'red'
            };

            globalStatus = colors[globalStatus] || "red";
            icons = {
                'green': globalStatus + ' host-status pficon pficon-ok status-ok',
                'yellow': globalStatus + ' host-status pficon pficon-info status-warn',
                'red': globalStatus + ' host-status pficon pficon-error-circle-o status-error'
            };

            return icons[globalStatus];
        };
    }
);
