(function () {
    'use strict';

    /**
     * @ngdoc service
     * @name  Bastion.common.service:ModuleStreamActions
     *
     * @description
     *   Provides common list of actions for module streams
     */

    function ModuleStreamActions(translate) {
        this.getActions = function() {
            return [
                { action: 'enable', description: translate("Enable")},
                { action: 'disable', description: translate("Disable")},
                { action: 'install', description: translate("Install")},
                { action: 'update', description: translate("Update")},
                { action: 'remove', description: translate("Remove")},
                { action: 'reset', description: translate("Reset")}
            ];
        };
    }

    angular.module('Bastion.common').service('ModuleStreamActions', ModuleStreamActions);
    ModuleStreamActions.$inject = ['translate'];
})();
