// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

Cypress.Commands.add('login', (username = "admin", password = "changeme") => {
  let authToken;

  // Prevent issues during repeat test runs
  cy.clearCookies();
  // Can't get auth token as JSON so we visit the page and grab from the meta tag
  cy.visit("/");
  cy.get('head meta[name="csrf-token"]').then(meta_tag => {
    authToken = meta_tag[0].content;

    // Submit the login as network request to save time
    cy.request({
      url: "users/login",
      method: "POST",
      form: true,
      body: {
        authenticity_token: authToken,
        login: {
          login: username,
          password, password
        }
     }
    });
  });
});