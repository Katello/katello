import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form, FormGroup, Button } from 'patternfly-react';
import { LinkContainer } from 'react-router-bootstrap';
import TooltipButton from 'react-bootstrap-tooltip-button';
import { noop } from 'foremanReact/common/helpers';

import Search from '../../../../components/Search/index';

const SubscriptionsToolbar = ({
  disableManifestActions,
  disableManifestReason,
  disableDeleteButton,
  disableDeleteReason,
  disableAddButton,
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
              disabled={disableManifestActions || disableAddButton}
            >
              <TooltipButton
                tooltipId="add-subscriptions-button-tooltip"
                tooltipText={disableManifestReason}
                tooltipPlacement="top"
                title={__('Add Subscriptions')}
                disabled={disableManifestActions}
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
              tooltipText={disableDeleteReason}
              tooltipPlacement="top"
              title={__('Delete')}
              disabled={disableManifestActions || disableDeleteButton}
            />

          </FormGroup>
        </div>
      </Form>
    </Col>
  </Row>
);

SubscriptionsToolbar.propTypes = {
  ...Search.propTypes,
  disableManifestActions: PropTypes.bool,
  disableManifestReason: PropTypes.string,
  disableDeleteButton: PropTypes.bool,
  disableDeleteReason: PropTypes.string,
  disableAddButton: PropTypes.bool,
  onDeleteButtonClick: PropTypes.func,
  onManageManifestButtonClick: PropTypes.func,
  onExportCsvButtonClick: PropTypes.func,
};

SubscriptionsToolbar.defaultProps = {
  ...Search.defaultProps,
  disableManifestActions: false,
  disableManifestReason: '',
  disableDeleteButton: false,
  disableDeleteReason: '',
  disableAddButton: false,
  onDeleteButtonClick: noop,
  onManageManifestButtonClick: noop,
  onExportCsvButtonClick: noop,
};

export default SubscriptionsToolbar;
