import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form, FormGroup, Button } from 'patternfly-react';
import { LinkContainer } from 'react-router-bootstrap';
import TooltipButton from 'react-bootstrap-tooltip-button';
import { noop } from 'foremanReact/common/helpers';

import Search from '../../../../components/Search/index';

const SubscriptionsToolbar = ({
  manifestActionsDisabled,
  manifestActionsDisabledReason,
  deleteButtonDisabled,
  deleteButtonDisabledReason,
  addButtonDisabled,
  getAutoCompleteParams,
  updateSearchQuery,
  onDeleteButtonClick,
  onSearch,
  onManageManifestButtonClick,
  onExportCsvButtonClick,
}) => (
  <Row className="toolbar-pf table-view-pf-toolbar-external">
    <Col sm={12}>
      <Form className="toolbar-pf-actions">
        <FormGroup className="toolbar-pf-filter">
          <Search
            onSearch={onSearch}
            getAutoCompleteParams={getAutoCompleteParams}
            updateSearchQuery={updateSearchQuery}
          />
        </FormGroup>

        <div className="toolbar-pf-action-right">
          <FormGroup>
            <LinkContainer
              to="subscriptions/add"
              disabled={manifestActionsDisabled || addButtonDisabled}
            >
              <TooltipButton
                tooltipId="add-subscriptions-button-tooltip"
                tooltipText={manifestActionsDisabledReason}
                tooltipPlacement="top"
                title={__('Add Subscriptions')}
                disabled={manifestActionsDisabled}
                bsStyle="primary"
              />
            </LinkContainer>

            <Button onClick={onManageManifestButtonClick}>
              {__('Manage Manifest')}
            </Button>

            <Button
              onClick={onExportCsvButtonClick}
            >
              {__('Export CSV')}
            </Button>

            <TooltipButton
              bsStyle="danger"
              onClick={onDeleteButtonClick}
              tooltipId="delete-subscriptions-button-tooltip"
              tooltipText={deleteButtonDisabledReason}
              tooltipPlacement="top"
              title={__('Delete')}
              disabled={manifestActionsDisabled || deleteButtonDisabled}
            />

          </FormGroup>
        </div>
      </Form>
    </Col>
  </Row>
);

SubscriptionsToolbar.propTypes = {
  ...Search.propTypes,
  manifestActionsDisabled: PropTypes.bool,
  manifestActionsDisabledReason: PropTypes.string,
  deleteButtonDisabled: PropTypes.bool,
  deleteButtonDisabledReason: PropTypes.string,
  addButtonDisabled: PropTypes.bool,
  onDeleteButtonClick: PropTypes.func,
  onManageManifestButtonClick: PropTypes.func,
  onExportCsvButtonClick: PropTypes.func,
};

SubscriptionsToolbar.defaultProps = {
  ...Search.defaultProps,
  manifestActionsDisabled: false,
  manifestActionsDisabledReason: '',
  deleteButtonDisabled: false,
  deleteButtonDisabledReason: '',
  addButtonDisabled: false,
  onDeleteButtonClick: noop,
  onManageManifestButtonClick: noop,
  onExportCsvButtonClick: noop,
};

export default SubscriptionsToolbar;
