/**
 * @ngdoc service
 * @name  Bastion.content-hosts.service:ContentHostsHelper
 *
 * @description
 *   Helper service that contains functionality common amongst content hosts.
 */
angular.module('Bastion.content-hosts').service('ContentHostsHelper',
    function () {
        function memoryInGigabytes(memStr) {
            var mems,
                memory,
                unit;

            if (angular.isUndefined(memStr) || memStr === "") {
                return "0";
            }

            mems = memStr.split(/\s+/);
            memory = parseFloat(mems[0]);
            unit = mems[1];

            switch (unit) {

            case 'B':
                memory = 0;
                break;

            case 'kB':
                memory = 0;
                break;

            case 'MB':
                memory /= 1024;
                break;

            case 'GB':
                break;

            case 'TB':
                memory *= 1024;
                break;

            default:
                // by default memory is in kB
                memory /= (1024 * 1024);
                break;

            }

            memory = Math.round(memory * 100) / 100;
            return memory;
        }

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

        this.memory = function (facts) {
            var mem;
            if (angular.isDefined(facts)) {
                if (angular.isDefined(facts.memory)) {
                    mem = facts.memory.memtotal;
                }
                if (angular.isUndefined(mem) && angular.isDefined(facts.dmi) &&
                   angular.isDefined(facts.dmi.memory)) {
                    mem = facts.dmi.memory.size;
                }
                return memoryInGigabytes(mem);
            }

            return "0";
        };

    }
);
