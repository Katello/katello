export default function routes($urlRouterProvider, $locationProvider) {
  $locationProvider.html5Mode({
    enabled: true,
    requireBase: false
  });
  $urlRouterProvider.otherwise('/');
}

routes.$inject = ['$urlRouterProvider', '$locationProvider'];
