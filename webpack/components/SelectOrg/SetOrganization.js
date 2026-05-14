import React, { useState, useEffect } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  Button,
  Card,
  CardBody,
  Title,
  Grid,
  GridItem,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { useDispatch, useSelector } from 'react-redux';
import { getOrganiztionsList } from './SelectOrgAction';
import reducer from './SelectOrgReducer';
import { LoadingState } from '../../components/LoadingState';
import './SelectOrg.scss';

const SetOrganization = () => {
  const [selectedOrgId, setSelectedOrgId] = useState('');
  const dispatch = useDispatch();

  const list = useSelector(state => state.katello.setOrganization.list) || [];
  const loading = useSelector(state => state.katello.setOrganization.loading);

  useEffect(() => {
    dispatch(getOrganiztionsList());
  }, [dispatch]);

  const isDisabled = !selectedOrgId;

  return (
    <Grid hasGutter>
      <GridItem span={6} offset={3}>
        <Card id="select-org" ouiaId="select-org-card">
          <CardBody>
            <LoadingState loading={loading} loadingText={__('Loading')}>
              <Form>
                <Title headingLevel="h1" size="2xl" className="pf-v5-u-text-align-center" ouiaId="select-org-title">
                  {__('Select an Organization')}
                </Title>
                <p className="pf-v5-u-text-align-center">
                  {__('The page you are attempting to access requires selecting a specific organization.')}
                </p>
                <p className="pf-v5-u-text-align-center">
                  {__('Please select one from the list below and you will be redirected.')}
                </p>

                <FormGroup fieldId="organization">
                  <Flex alignItems={{ default: 'alignItemsFlexStart' }}>
                    <FlexItem flex={{ default: 'flex_1' }}>
                      <FormSelect
                        ouiaId="select-org-select"
                        value={selectedOrgId}
                        id="organization"
                        name="organization"
                        onChange={(_event, value) => setSelectedOrgId(value)}
                        aria-label={__('Select an organization')}
                      >
                        <FormSelectOption
                          key="placeholder"
                          value=""
                          label={__('Select an organization')}
                          isDisabled
                        />
                        {list.map(({ id, name }) => (
                          <FormSelectOption
                            key={id}
                            value={id}
                            label={name}
                          />
                        ))}
                      </FormSelect>
                    </FlexItem>
                    <FlexItem>
                      <Button
                        variant="primary"
                        isDisabled={isDisabled}
                        ouiaId="select-org-button"
                        onClick={() => {
                          if (selectedOrgId) {
                            window.location.href = `/organizations/${selectedOrgId}/select`;
                          }
                        }}
                      >
                        {__('Select')}
                      </Button>
                    </FlexItem>
                  </Flex>
                </FormGroup>
              </Form>
            </LoadingState>
          </CardBody>
        </Card>
      </GridItem>
    </Grid>
  );
};

export const setOrganization = reducer;

export default SetOrganization;
