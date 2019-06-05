routes.$inject = ['$stateProvider'];

export default function routes($stateProvider) {
  $stateProvider
  .state('angularTest', {
    url: '/angular_test',
    template: require('./angularTest.html')
  });
}