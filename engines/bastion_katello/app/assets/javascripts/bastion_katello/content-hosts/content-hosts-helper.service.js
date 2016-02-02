/**
 * @ngdoc service
 * @name  Bastion.content-hosts.service:ContentHostsHelper
 *
 * @description
 *   Helper service that contains functionality common amongst content hosts.
 */
angular.module('Bastion.content-hosts').service('ContentHostsHelper',
    function () {
        this.getSubscriptionStatusColor = function (status) {
            var colors = {
                    'valid': 'green',
                    'partial': 'yellow',
                    'invalid': 'red',
                    0: 'green',
                    1: 'yellow',
                    2: 'red',
                    3: 'red'
                };

            return colors[status] ? colors[status] : 'red';
        };

        this.getGlobalStatusColor = function (status) {
            var colors = {
                    0: 'green',
                    1: 'yellow',
                    2: 'red'
                };

            return colors[status] ? colors[status] : 'red';
        };
    }
);
