/* eslint-disable */
import React from 'react';
import { EmptyState as PfEmptyState, Button } from 'patternfly-react';
import { LinkContainer } from 'react-router-bootstrap';

const EmptyState = (props) => {
  const {
    icon = 'add-circle-o',
    header,
    description,
    customDocumentation,
    documentationLabel = __('For more information please see'),
    documentationButton = __('Documentation'),
    docUrl,
    action,
    secondayActions,
  } = props;
  const defaultDocumantion = `${documentationLabel} <a href=${docUrl}>${documentationButton}</a>`;
  const showDocsLink = !!(docUrl || customDocumentation);

  return (
    <PfEmptyState>
      <PfEmptyState.Icon type="pf" name={icon} />
      <PfEmptyState.Title>{header}</PfEmptyState.Title>
      <PfEmptyState.Info>{description}</PfEmptyState.Info>
      {showDocsLink && (
        <PfEmptyState.Help>
          {customDocumentation || <span dangerouslySetInnerHTML={{ __html: defaultDocumantion }} />}
        </PfEmptyState.Help>
      )}
      {action && (
        <PfEmptyState.Action>
          <LinkContainer to={action.url}>
            <Button href={action.url} bsStyle="primary" bsSize="large">
              {action.title}
            </Button>
          </LinkContainer>
        </PfEmptyState.Action>
      )}
      {secondayActions && (
        <PfEmptyState.Action secondary>
          {secondayActions.map(item => (
            <LinkContainer to={item.url}>
              <Button href={item.url} title={item.title}>
                {item.title}
              </Button>
            </LinkContainer>
          ))}
        </PfEmptyState.Action>
        )}
    </PfEmptyState>
  );
};
export default EmptyState;
