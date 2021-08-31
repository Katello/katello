import { useState, useRef } from 'react';

const useSet = (initialArry) => {
  const set = useRef(new Set(initialArry));
  const [, setToggle] = useState(false);
  const forceRender = () => setToggle(prev => !prev);
  return [set.current, forceRender];
};

export default useSet;
