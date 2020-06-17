import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  TextContent,
  TextList,
  TextListVariants,
  TextListItem,
  TextListItemVariants,
  Tooltip,
  TooltipPosition,
} from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';

import { updateContentView } from './ContentViewDetailActions';
import { selectCVUpdating } from './ContentViewDetailSelectors';
import EditableTextInput from '../../../components/EditableTextInput';
import Loading from '../../../components/Loading';
import EditableCheckbox from '../../../components/EditableCheckbox';
import './contentViewInfo.scss';

const ContentViewInfo = ({ cvId, info }) => {
  const dispatch = useDispatch();
  const updating = useSelector(state => selectCVUpdating(state));

  if (updating) return <Loading size="sm" showText={false} />;
  return (
    <TextContent>
      <TextList component={TextListVariants.dl}>
        {Object.keys(info).map((key) => {
          const onEdit = val => dispatch(updateContentView(cvId, { [key]: val }));
          const {
            label,
            value,
            textArea = false,
            editable = true,
            boolean = false,
            tooltip,
          } = info[key];
          const displayProps = {
 label: key, value, onEdit, editable,
};
          return (
            <React.Fragment key={key}>
              <TextListItem component={TextListItemVariants.dt}>
                {label}
                {tooltip &&
                <span className="foreman-spaced-icon">
                  <Tooltip
                    position={TooltipPosition.top}
                    content={tooltip}
                  >
                    <OutlinedQuestionCircleIcon />
                  </Tooltip>
                </span>
              }
              </TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {boolean ?
                  <EditableCheckbox {...displayProps} /> :
                  <EditableTextInput {...{ ...displayProps, textArea }} />
                }
              </TextListItem>
            </React.Fragment>
          );
        })}
      </TextList>
    </TextContent>
  );
};

ContentViewInfo.propTypes = {
  cvId: PropTypes.number.isRequired,
  info: PropTypes.objectOf(PropTypes.shape({
    value: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
    label: PropTypes.string,
    boolean: PropTypes.bool,
    editable: PropTypes.bool,
    tooltip: PropTypes.string,
    textArea: PropTypes.bool,
  })).isRequired,
};

export default ContentViewInfo;
