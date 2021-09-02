import { useState, useRef } from 'react';

const useSet = (initialArry) => {
  const set = useRef(new Set(initialArry));
  const [, setToggle] = useState(false);
  // needed because mutating a Ref won't cause React to rerender
  const forceRender = () => setToggle(prev => !prev);
  return [set.current, forceRender];
};

export default useSet;
