describe('Login', () => {
  beforeEach(() => {
    cy.login();
  });

  it('User is logged in', () => {
    cy.visit("/")
    cy.contains("Welcome").should("not.be.visible");
    cy.contains("Default Organization").should('be.visible');
    cy.contains("Default Location").should('be.visible');
  });
});

