-- function for debian version comparison

--compare two numbers
CREATE OR REPLACE FUNCTION deb_version_cmp_num(_left text, _right text) 
RETURNS integer 
--return -1 if left > right
--return 0 if left = right
--return 1 if left < right
AS $$
DECLARE
  lint numeric;
  rint numeric;
BEGIN
  --'0' and '' are compared as equal in the dpkg implementation
  IF _left = '' THEN
    _left = '0';
  END IF;
  IF _right = '' THEN
    _right = '0';
  END IF;
  lint := CAST (_left AS numeric);
  rint := CAST (_right AS numeric);
  IF lint < rint THEN
    RETURN -1;
  ELSIF lint > rint THEN
    RETURN 1;
  ELSE 
    RETURN 0;
  END IF;
END;
$$ IMMUTABLE STRICT LANGUAGE plpgsql;

--compare two strings without digits
CREATE OR REPLACE FUNCTION deb_version_cmp_al(_left text, _right text)
RETURNS integer
--return -1 if left > right
--return 0 if left = right
--return 1 if left < right
AS $$
DECLARE
  lpair text ARRAY[2];
  rpair text ARRAY[2];
BEGIN
  --go through the string character by character and compare
  lpair := ARRAY['', _left];
  rpair := ARRAY['', _right];

  LOOP
  --for each character do:
    IF lpair[2] = '' AND rpair[2] = '' THEN
      --both strings are equal and remaining characters are empty
      return 0;
    END IF;
    
    --get the next character into l/rpair[1]
    lpair := regexp_matches(lpair[2], '(.?)(.*)');
    rpair := regexp_matches(rpair[2], '(.?)(.*)');

    IF lpair[1] = rpair[1] THEN
      --characters are equal, continue with next character
      CONTINUE;
    END IF;
    --tilde comes before any other character and befor the empty string
    IF lpair[1] = '~' THEN
      RETURN -1;
    END IF;
    IF rpair[1] = '~' THEN
      RETURN 1;
    END IF;
    --next check for empty string
    IF lpair[1] = '' THEN
      RETURN -1;
    END IF;
    IF rpair[1] = '' THEN
      RETURN 1;
    END IF;
    --else order by ascii value of character
    IF lpair[1] SIMILAR TO '[a-zA-Z]' THEN
      IF rpair[1] SIMILAR TO '[a-zA-Z]' AND ascii(lpair[1]) > ascii(rpair[1]) THEN
        RETURN 1;
      END IF;
      RETURN -1;
    END IF;
    IF rpair[1] SIMILAR TO '[a-zA-Z]' THEN
      RETURN 1;
    END IF;
    IF ascii(lpair[1]) < ascii(rpair[1]) THEN
      RETURN -1;
    END IF;
    RETURN 1;
  END LOOP;
END;
$$ IMMUTABLE STRICT LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION deb_version_cmp_string(lstring text, rstring text, _left text, _right text, version boolean)
RETURNS integer
--return -1 if left > right
--return 0 if left = right
--return 1 if left < right
AS $$
DECLARE
  lpair text ARRAY[2];
  rpair text ARRAY[2];
  res integer;
BEGIN
  --split of digits and non-digits part
  lpair[1] := LEFT (lstring, 1);
  rpair[1] := LEFT (rstring, 1);
  lpair[2] := lstring;
  rpair[2] := rstring;

  
  --if first characters are digit and non-digit (this is faulty for version)
  IF lpair[1] SIMILAR TO '[a-zA-Z\.\:\+\~\-]' THEN
    IF version THEN
      RAISE WARNING 'version % has bad syntax: version number does not start with digit', _left;
    END IF;
    IF rpair[1] SIMILAR TO '[0-9]' THEN
      RETURN 1;
    END IF;
  ELSIF rpair[1] SIMILAR TO '[a-zA-Z\.\:\+\~\-]' THEN
    IF version THEN
      RAISE WARNING 'version % has bad syntax: version number does not start with digit', _right;
    END IF;
    RETURN -1;
  END IF;

  --compare versions
  LOOP
    --if no more characters to compare, strings are equal
    IF lpair[2] = '' AND rpair[2] = '' THEN
      return 0;
    END IF;

    --cut off digit part starting from beginning and rest
    lpair := regexp_matches(lpair[2], '([0-9]*)(.*)');
    rpair := regexp_matches(rpair[2], '([0-9]*)(.*)');
    
    --compare digit part
    res := deb_version_cmp_num(lpair[1], rpair[1]);
    IF res != 0 THEN
      RETURN res;
    END IF;

    --cut off into largest non-digit part starting from beginning and rest
    lpair := regexp_matches(lpair[2], '([^0-9]*)(.*)');
    rpair := regexp_matches(rpair[2], '([^0-9]*)(.*)');

    --compare non-digit part
    res := deb_version_cmp_al(lpair[1], rpair[1]);
    IF res != 0 THEN
      RETURN res;
    END IF;
  END LOOP;
END
$$ IMMUTABLE STRICT LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION deb_version_cmp(_left text, _right text)
RETURNS integer
--return -1 if left > right
--return 0 if left = right
--return 1 if left < right
AS $$
DECLARE
  lepochver text ARRAY[2];
  repochver text ARRAY[2];
  lverrev text ARRAY[2];
  rverrev text ARRAY[2];
  res integer;
BEGIN
  --split in epoch and version+revision
  lepochver := regexp_matches(_left, '(?:([0-9]*):)?(.*)');
  lepochver[1] := coalesce(lepochver[1], '0');
  repochver := regexp_matches(_right, '(?:([0-9]*):)?(.*)');
  repochver[1] := coalesce(repochver[1], '0');
  
  --compare epoch
  res := deb_version_cmp_num(lepochver[1], repochver[1]);
  IF res != 0 THEN
    RETURN res;
  END IF;
  
  --split in version and revision
  lverrev := regexp_matches(lepochver[2], '(.*?)(?:-([a-zA-Z0-9\+\.~]*))?$');
  lverrev[2] := coalesce(lverrev[2], '');
  rverrev := regexp_matches(repochver[2], '(.*?)(?:-([a-zA-Z0-9\+\.~]*))?$');
  rverrev[2] := coalesce(rverrev[2], '');
  
  --compare version
  res := deb_version_cmp_string(lverrev[1], rverrev[1], _left, _right, TRUE);
  IF res != 0 THEN
    RETURN res;
  END IF;
  
  --compare revision
  res := deb_version_cmp_string(lverrev[2], rverrev[2], _left, _right, FALSE);
  RETURN res;
END
$$ IMMUTABLE STRICT LANGUAGE plpgsql;
