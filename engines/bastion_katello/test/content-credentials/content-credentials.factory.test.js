describe("Factory: ContentCredential", function() {
  var $httpBackend, contentCredentials, contentCredential;

  beforeEach(module("Bastion.content-credentials", "Bastion.test-mocks"));

  beforeEach(
    module(function($provide) {
      contentCredential = {
        name: "fakegpg",
        content_type: "gpg_key",
        content: "hello",
        id: 2,
        organization_id: 4,
        organization: { name: "org-4351", label: "org-4351", id: 4 },
        created_at: "2018-12-04 16:05:47 -0500",
        updated_at: "2018-12-04 16:05:47 -0500",
        gpg_key_products: [
          {
            id: 1,
            cp_id: "644602083972",
            name: "test_product",
            provider: { name: "Anonymous", id: 17 },
            repository_count: 5
          }
        ],
        gpg_key_repos: [
          {
            id: 5,
            name: "fakegpg",
            content_type: "yum",
            product: { id: 1, cp_id: "644602083972", name: "test_product" }
          },
          {
            id: 1,
            name: "yum",
            content_type: "yum",
            product: { id: 1, cp_id: "644602083972", name: "test_product" }
          }
        ],
        ssl_ca_products: [],
        ssl_ca_root_repos: [],
        ssl_client_products: [],
        ssl_client_root_repos: [],
        ssl_key_products: [],
        ssl_key_root_repos: [],
        permissions: {
          view_content_credenials: true,
          edit_content_credenials: true,
          destroy_content_credenials: true
        }
      };

      contentCredentials = {
        records: [
          contentCredential          
        ],
        total: 2,
        subtotal: 1
      };

      $provide.value("CurrentOrganization", "ACME");
    })
  );

  beforeEach(inject(function($injector) {
    $httpBackend = $injector.get("$httpBackend");
    ContentCredential = $injector.get("ContentCredential");
  }));

  afterEach(function() {
    $httpBackend.flush();
    $httpBackend.verifyNoOutstandingExpectation();
    $httpBackend.verifyNoOutstandingRequest();
  });

  it("provides a way to get a list of repositories", function() {
    $httpBackend
      .expectGET("katello/api/v2/content_credentials?organization_id=ACME")
      .respond(contentCredentials);

    ContentCredential.queryPaged(function(contentCredentials) {
      expect(contentCredentials.records.length).toBe(1);
    });
  });

  it("provide a way to get a single content credential's repositories", function() {
    $httpBackend
      .expectGET("katello/api/v2/content_credentials/1/repositories?organization_id=ACME")
      .respond(contentCredential);

    ContentCredential.repositories({id: 1, action: 'repositories'}, function(response) {
      var results = response.results;
      expect(results.length).toBe(2);
      angular.forEach(results, function(result) {
        expect(result.name).toBeDefined();
        expect(result.content_type).toBe('yum');
        expect(result.usedAs).toBe('GPG Key');
      })
    });
  });

  it("provide a way to get a single content credential's products", function() {
    $httpBackend
      .expectGET("katello/api/v2/content_credentials/1/products?organization_id=ACME")
      .respond(contentCredential);

    ContentCredential.products({id: 1, action: 'products'}, function(response) {
      var results = response.results;
      expect(results.length).toBe(1);
      angular.forEach(results, function(result) {
        expect(result.name).toBeDefined();
        expect(result.usedAs).toBe('GPG Key');
      })
    });
  });
});
