/**
 * @ngdoc service
 * @name  Bastion.capsule-content.service:syncState
 *
 * @description
 *   Provides a syncState that keeps capsule sync UI state.
 */
angular.module('Bastion.capsule-content').service('syncState', function () {

    this.DEFAULT = 'DEFAULT';
    this.SYNCING = 'SYNCING';
    this.SYNC_TRIGGERED = 'SYNC_TRIGGERED';
    this.CANCEL_TRIGGERED = 'CANCEL_TRIGGERED';
    this.FAILURE = 'FAILURE';

    this.set = function (state) {
        this.state = state;
        return this.state;
    };

    this.is = function () {
        return _.includes(arguments, this.state || this.DEFAULT);
    };

});
