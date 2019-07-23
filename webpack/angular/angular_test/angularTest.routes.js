import angularTestController from './angularTest.controller.js';

routes.$inject = ['$stateProvider'];

export default function routes($stateProvider) {
  $stateProvider
    .state('angularTest', {
      url: '/angular_test',
      controller: angularTestController,
      template: require('./angularTest.html')
    });
}
