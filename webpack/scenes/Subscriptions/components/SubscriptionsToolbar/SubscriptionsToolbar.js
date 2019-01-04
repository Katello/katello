import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { Row, Col, Form, FormGroup, Button } from '@theforeman/vendor/patternfly-react';
import { LinkContainer } from '@theforeman/vendor/react-router-bootstrap';
import TooltipButton from '@theforeman/vendor/react-bootstrap-tooltip-button';
import { noop } from 'foremanReact/common/helpers';

import Search from '../../../../components/Search/index';
import OptionTooltip from '../../../../move_to_pf/OptionTooltip';

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
  tableColumns,
  toolTipOnChange,
  toolTipOnclose,
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
        <div className="option-tooltip-container">
          <OptionTooltip options={tableColumns} icon="fa-columns" id="subscriptionTableTooltip" onChange={toolTipOnChange} onClose={toolTipOnclose} />
        </div>
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
  tableColumns: OptionTooltip.propTypes.options,
  disableManifestActions: PropTypes.bool,
  disableManifestReason: PropTypes.string,
  disableDeleteButton: PropTypes.bool,
  disableDeleteReason: PropTypes.string,
  disableAddButton: PropTypes.bool,
  onDeleteButtonClick: PropTypes.func,
  onManageManifestButtonClick: PropTypes.func,
  onExportCsvButtonClick: PropTypes.func,
  toolTipOnChange: PropTypes.func,
  toolTipOnclose: PropTypes.func,
};

SubscriptionsToolbar.defaultProps = {
  ...Search.defaultProps,
  tableColumns: [],
  disableManifestActions: false,
  disableManifestReason: '',
  disableDeleteButton: false,
  disableDeleteReason: '',
  disableAddButton: false,
  onDeleteButtonClick: noop,
  onManageManifestButtonClick: noop,
  onExportCsvButtonClick: noop,
  toolTipOnChange: noop,
  toolTipOnclose: noop,
};

export default SubscriptionsToolbar;
