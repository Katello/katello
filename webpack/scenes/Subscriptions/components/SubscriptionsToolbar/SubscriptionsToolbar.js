import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form, FormGroup, Button } from 'patternfly-react';
import { LinkContainer } from 'react-router-bootstrap';
import { noop } from 'foremanReact/common/helpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { SUBSCRIPTIONS_SERVICE_URL } from '../../SubscriptionConstants';

import Search from '../../../../components/Search/index';
import TooltipButton from '../../../../components/TooltipButton';
import OptionTooltip from '../../../../components/OptionTooltip';

const SubscriptionsToolbar = ({
  canManageSubscriptionAllocations,
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
  isManifestImported,
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
            {canManageSubscriptionAllocations &&
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
            }

            {isManifestImported &&
              <a
                href={SUBSCRIPTIONS_SERVICE_URL}
                className="btn btn-default"
                target="_blank"
                rel="noreferrer"
              >
                {__('View Subscription Usage')}
              </a>
            }

            <Button onClick={onManageManifestButtonClick}>
              {__('Manage Manifest')}
            </Button>

            <Button
              onClick={onExportCsvButtonClick}
            >
              {__('Export CSV')}
            </Button>
            {canManageSubscriptionAllocations &&

              <TooltipButton
                bsStyle="danger"
                onClick={onDeleteButtonClick}
                tooltipId="delete-subscriptions-button-tooltip"
                tooltipText={disableDeleteReason}
                tooltipPlacement="top"
                title={__('Delete')}
                disabled={disableManifestActions || disableDeleteButton}
              />
            }
          </FormGroup>
        </div>
      </Form>
    </Col>
  </Row>
);

SubscriptionsToolbar.propTypes = {
  ...Search.propTypes,
  tableColumns: OptionTooltip.propTypes.options,
  canManageSubscriptionAllocations: PropTypes.bool,
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
