import React, { useImperativeHandle, useRef } from 'react';
import { DragSource, DropTarget } from 'react-dnd';
import PropTypes from 'prop-types';
import { set } from 'lodash';

const onHover = (
  dragIndex,
  hoverIndex,
  hoverBoundingRect,
  monitor,
  clientAttr,
  rectMaxAttr,
  rectMinAttr,
) => {
  const hoverMiddle =
    (hoverBoundingRect[rectMaxAttr] - hoverBoundingRect[rectMinAttr]) / 2;
  const clientOffset = monitor.getClientOffset();
  const hoverClient = clientOffset[clientAttr] - hoverBoundingRect[rectMinAttr];

  if (dragIndex < hoverIndex && hoverClient < hoverMiddle) {
    return false;
  }

  if (dragIndex > hoverIndex && hoverClient > hoverMiddle) {
    return false;
  }

  return true;
};

export const makeOnHover = (getIndex, getMoveFnc, direction) => (
  props,
  monitor,
  component,
) => {
  const dragIndex = monitor.getItem().index;
  const hoverIndex = getIndex(props);

  if (dragIndex === hoverIndex) {
    return null;
  }

  const hoverBoundingRect = component.getNode().getBoundingClientRect();
  let shouldMove = false;

  if (direction === 'vertical') {
    shouldMove = onHover(
      dragIndex,
      hoverIndex,
      hoverBoundingRect,
      monitor,
      'y',
      'bottom',
      'top',
    );
  } else if (direction === 'horizontal') {
    shouldMove = onHover(
      dragIndex,
      hoverIndex,
      hoverBoundingRect,
      monitor,
      'x',
      'right',
      'left',
    );
  } else {
    throw new Error(`Unknown drag direction, expected one of: horizontal, vertical, got: ${direction}`);
  }

  if (!shouldMove) {
    return null;
  }

  getMoveFnc(props)(dragIndex, hoverIndex);
  const draggedItem = monitor.getItem();
  draggedItem.index = hoverIndex;

  return null;
};

const getDropTarget = (dropTypes, getIndex, getMoveFnc, direction) =>
  DropTarget(
    dropTypes,
    { hover: makeOnHover(getIndex, getMoveFnc, direction) },
    connect => ({
      connectDropTarget: connect.dropTarget(),
    }),
  );

const getDragSource = (dragType, getIndex, getItem) =>
  DragSource(
    dragType,
    {
      beginDrag: props => set(getItem(props), 'index', getIndex(props)),
    },
    (connect, monitor) => ({
      connectDragSource: connect.dragSource(),
      isDragging: monitor.isDragging(),
    }),
  );

export const orderable = (
  Component,
  {
    type = 'orderable',
    direction = 'horizontal',
    getItem = props => ({ id: props.id }),
    getIndex = props => props.index,
    getMoveFnc = props => props.moveValue,
  },
) => {
  const Orderable = React.forwardRef(({
    isDragging, styleOnDrag, connectDragSource, connectDropTarget, ...props
  }, ref) => {
    const elementRef = useRef(null);
    connectDragSource(elementRef);
    connectDropTarget(elementRef);
    useImperativeHandle(ref, () => ({
      getNode: () => elementRef.current,
    }));

    return (
      <div ref={elementRef} style={isDragging ? styleOnDrag : null}>
        <Component isDragging={isDragging} {...props} />
      </div>
    );
  });
  Orderable.displayName = `Orderable(${Component.displayName ||
    Component.name ||
    'Component'})`;

  Orderable.propTypes = {
    isDragging: PropTypes.bool.isRequired,
    connectDragSource: PropTypes.func.isRequired,
    connectDropTarget: PropTypes.func.isRequired,
    styleOnDrag: PropTypes.shape({ opacity: PropTypes.number }),
  };

  Orderable.defaultProps = {
    styleOnDrag: { opacity: 0.6 },
  };

  return getDropTarget(
    type,
    getIndex,
    getMoveFnc,
    direction,
  )(getDragSource(type, getIndex, getItem)(Orderable));
};
