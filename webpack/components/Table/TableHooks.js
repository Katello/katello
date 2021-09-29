import { useState, useRef } from 'react';

class ReactConnectedSet extends Set {
  constructor(initialValue, forceRender) {
    super();
    this.forceRender = forceRender;
    // The constructor would normally call add() with the initial value, but since we
    // must call super() at the top, this.forceRender() isn't defined yet.
    // So, we call super() above with no argument, then call add() manually below
    // after forceRender is defined.
    if (initialValue) {
      if (initialValue.constructor.name === 'Array') {
        initialValue.forEach(val => this.add(val));
      } else {
        this.add(initialValue);
      }
    }
  }
  add(value) {
    const result = super.add(value); // ensuring these methods have the same API as the superclass
    this.forceRender();
    return result;
  }

  clear() {
    const result = super.clear();
    this.forceRender();
    return result;
  }

  delete(value) {
    const result = super.delete(value);
    this.forceRender();
    return result;
  }

  onToggle(isOpen, id) {
    if (isOpen) {
      this.add(id);
    } else {
      this.delete(id);
    }
  }
}

const useSet = (initialArry) => {
  const [, setToggle] = useState(0);
  // needed because mutating a Ref won't cause React to rerender
  const forceRender = () => setToggle(prev => prev + 1);
  const set = useRef(new ReactConnectedSet(initialArry, forceRender));
  return set.current;
};

export default useSet;
