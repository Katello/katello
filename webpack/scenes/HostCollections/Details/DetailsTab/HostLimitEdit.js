import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Button,
  Checkbox,
  Flex,
  FlexItem,
  FormGroup,
  NumberInput,
} from '@patternfly/react-core';
import { CheckIcon, TimesIcon, PencilAltIcon } from '@patternfly/react-icons';
import { updateHostCollection, getHostCollection } from '../HostCollectionDetailsActions';

const HostLimitEdit = ({ hostCollection, hostCollectionId }) => {
  const dispatch = useDispatch();
  const [isEditing, setIsEditing] = useState(false);
  const [isUnlimited, setIsUnlimited] = useState(hostCollection?.unlimitedHosts || false);
  const [maxHosts, setMaxHosts] = useState(hostCollection?.maxHosts || 1);

  const handleSave = () => {
    const params = {
      unlimited_hosts: isUnlimited,
      max_hosts: isUnlimited ? null : maxHosts,
    };

    dispatch(updateHostCollection(hostCollectionId, params, () => {
      dispatch(getHostCollection(hostCollectionId));
      setIsEditing(false);
    }));
  };

  const handleCancel = () => {
    setIsUnlimited(hostCollection?.unlimitedHosts || false);
    setMaxHosts(hostCollection?.maxHosts || 1);
    setIsEditing(false);
  };

  const displayValue = () => {
    if (hostCollection?.unlimitedHosts) {
      return __('Unlimited');
    }
    return String(hostCollection?.maxHosts || 0);
  };

  const onMinus = () => {
    const newValue = maxHosts - 1;
    if (newValue >= 1) {
      setMaxHosts(newValue);
    }
  };

  const onPlus = () => {
    setMaxHosts(maxHosts + 1);
  };

  const onChange = (event) => {
    const value = Number(event.target.value);
    if (!Number.isNaN(value) && value >= 1) {
      setMaxHosts(value);
    }
  };

  if (!isEditing) {
    return (
      <Flex className="inline-edit-display">
        <FlexItem flex={{ default: 'flex_1' }}>
          <span className="inline-edit-value">{displayValue()}</span>
        </FlexItem>
        <FlexItem>
          <Button
            variant="plain"
            aria-label="Edit"
            onClick={() => setIsEditing(true)}
            icon={<PencilAltIcon />}
            ouiaId="host-limit-edit-button"
          />
        </FlexItem>
      </Flex>
    );
  }

  return (
    <FormGroup className="inline-edit-form">
      <Flex direction={{ default: 'column' }}>
        <FlexItem>
          <Checkbox
            id="unlimited-checkbox"
            label={__('Unlimited')}
            isChecked={isUnlimited}
            onChange={setIsUnlimited}
            ouiaId="unlimited-checkbox"
          />
        </FlexItem>
        {!isUnlimited && (
          <FlexItem>
            <Flex alignItems={{ default: 'alignItemsCenter' }}>
              <FlexItem>
                <NumberInput
                  value={maxHosts}
                  onMinus={onMinus}
                  onChange={onChange}
                  onPlus={onPlus}
                  inputName="max-hosts"
                  inputAriaLabel="max hosts"
                  minusBtnAriaLabel="minus"
                  plusBtnAriaLabel="plus"
                  min={1}
                  ouiaId="max-hosts-input"
                />
              </FlexItem>
              <FlexItem>
                <Button
                  variant="plain"
                  aria-label="Save"
                  onClick={handleSave}
                  icon={<CheckIcon />}
                  ouiaId="host-limit-save-button"
                />
              </FlexItem>
              <FlexItem>
                <Button
                  variant="plain"
                  aria-label="Cancel"
                  onClick={handleCancel}
                  icon={<TimesIcon />}
                  ouiaId="host-limit-cancel-button"
                />
              </FlexItem>
            </Flex>
          </FlexItem>
        )}
        {isUnlimited && (
          <FlexItem>
            <Flex>
              <FlexItem>
                <Button
                  variant="plain"
                  aria-label="Save"
                  onClick={handleSave}
                  icon={<CheckIcon />}
                  ouiaId="host-limit-save-button-unlimited"
                />
              </FlexItem>
              <FlexItem>
                <Button
                  variant="plain"
                  aria-label="Cancel"
                  onClick={handleCancel}
                  icon={<TimesIcon />}
                  ouiaId="host-limit-cancel-button-unlimited"
                />
              </FlexItem>
            </Flex>
          </FlexItem>
        )}
      </Flex>
    </FormGroup>
  );
};

HostLimitEdit.propTypes = {
  hostCollection: PropTypes.shape({
    maxHosts: PropTypes.number,
    unlimitedHosts: PropTypes.bool,
  }),
  hostCollectionId: PropTypes.string.isRequired,
};

HostLimitEdit.defaultProps = {
  hostCollection: {},
};

export default HostLimitEdit;
