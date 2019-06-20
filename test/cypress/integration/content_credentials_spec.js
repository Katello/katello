describe('Content Credentials', () => {
  before(() => {
    cy.login();
  })

  beforeEach(() => {
    cy.fixture('content_credentials/details').as('contentCredDetails')
    Cypress.Cookies.preserveOnce('_session_id', 'remember_token')
  })

  // using function() in order to use aliased variables
  it('Visits top level page', function() {
    cy.visit("/content_credentials");
    cy.get('h2').contains('Content Credentials');
  })

  it('Can create new content credential', function() {
   cy.visit("/content_credentials/new");
   cy.get("@contentCredDetails").then(details => {
      cy.get('[name="name"]').type(details.name);
      cy.get('[name="content"]').type(details.content);
    });
    cy.get('[name="content_type"]').select("GPG Key");
    // We don't actually submit the form because it doesn't submit as an XHR request.
    // Only XHR requests are able to be stubbed in cypress.
    cy.contains('Save').should('be.visible');
  })

  it('Can view the details for a content credential', function() {
    // to re-record the response, use the following, adjusting the ids as necessary:
    // cy.request("katello/api/v2/content_credentials/29?organization_id=2").then(response => {
    //   cy.writeFile("test/cypress/fixtures/content_credentials/details.json", response.body);
    // })

    cy.server();
    cy.route(/katello\/api\/v2\/content_credentials\/\d+/, "@contentCredDetails")
    cy.visit(`/content_credentials/29`);

    cy.contains('Details').should('be.visible');
    cy.contains('GPG Key').should('be.visible');
    cy.get("@contentCredDetails").then(details => {
      cy.contains(details.name).should('be.visible');
      cy.contains(details.content).should('be.visible');
    });

    // Products tab
    cy.get('a').get('[ui-sref="content-credential.products"]')
               .contains("Products")
               .click();

    cy.get('table').within(() => {
      cy.get('span').contains('Name').should('be.visible');
      cy.get('span').contains('Used as').should('be.visible');
      cy.get('span').contains('Repositories').should('be.visible');
    });
    
    // Repositories tab
    cy.get('a').get('[ui-sref="content-credential.repositories"]')
               .contains("Repositories")
               .click();

    cy.get('table').within(() => {
      cy.get('span').contains('Name').should('be.visible');
      cy.get('span').contains('Product').should('be.visible');
      cy.get('span').contains('Used as').should('be.visible');
    });
  })

  it('Can view and delete content credential', function() {
    cy.server();
    cy.route("delete", /katello\/api\/v2\/content_credentials\/\d+/, {});
    cy.route("katello/api/v2/content_credentials", "fixture:content_credentials/list");

    cy.visit("/content_credentials");
    cy.get("@contentCredDetails").then(details => {
      cy.contains(details.name).click();
    });
    cy.contains("Remove Content Credential").click();
    cy.get("button").contains("Remove").click();
  })
})
