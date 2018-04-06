class AddDebVersionCmpFunctionToDb < ActiveRecord::Migration[4.2]
  # Implementation of version compare for debian packages
  # Reference: http://man7.org/linux/man-pages/man5/deb-version.5.html
  FUNCTIONS = "
        CREATE OR REPLACE FUNCTION deb_version_cmp_num(_left text, _right text) RETURNS integer AS $$
        DECLARE
          lint integer := 0;
          rint integer := 0;
          leftlen integer;
          rightlen integer;
          i integer := 0;
          MAXLEN CONSTANT integer := 7;
        BEGIN
          leftlen := char_length(_left);
          rightlen := char_length(_right);
          IF leftlen < rightlen THEN
            RETURN -1;
          ELSEIF leftlen > rightlen THEN
            RETURN 1;
          ELSE
            WHILE (i * MAXLEN) < leftlen LOOP
              IF _left != '' THEN
                lint := substring(_left from (i * MAXLEN) for MAXLEN) AS integer;
              END IF;
              IF _right != '' THEN
                rint := substring(_right from (i * MAXLEN) for MAXLEN) AS integer;
              END IF;
              IF lint < rint THEN
                RETURN -1;
              ELSEIF lint > rint THEN
                RETURN 1;
              END IF;
              i := i + 1;
            END LOOP;
          END IF;
          RETURN 0;
        END;
        $$ IMMUTABLE STRICT LANGUAGE plpgsql;

        CREATE OR REPLACE FUNCTION deb_version_cmp_al(_left text, _right text)
        RETURNS integer
        AS $$
        DECLARE
          lpair text ARRAY[2];
          rpair text ARRAY[2];
        BEGIN
          lpair := ARRAY['', _left];
          rpair := ARRAY['', _right];

          LOOP
            IF lpair[2] = '' AND rpair[2] = '' THEN
              return 0;
            END IF;

            lpair := regexp_matches(lpair[2], '(.?)(.*)');
            rpair := regexp_matches(rpair[2], '(.?)(.*)');

            IF lpair[1] = rpair[1] THEN
              CONTINUE;
            END IF;
            IF lpair[1] = '~' THEN
              RETURN -1;
            END IF;
            IF rpair[1] = '~' THEN
              RETURN 1;
            END IF;
            IF lpair[1] = '' THEN
              RETURN -1;
            END IF;
            IF rpair[1] = '' THEN
              RETURN 1;
            END IF;
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

        CREATE OR REPLACE FUNCTION deb_version_cmp(_left text, _right text)
        RETURNS integer
        AS $$
        DECLARE
          lpair text ARRAY[2];
          rpair text ARRAY[2];
          res integer;
        BEGIN
          lpair := regexp_matches(_left, '(?:(\\d*):)?(.*)');
          lpair[1] := coalesce(lpair[1], '');
          rpair := regexp_matches(_right, '(?:(\\d*):)?(.*)');
          rpair[1] := coalesce(rpair[1], '');

          res := deb_version_cmp_num(lpair[1], rpair[1]);
          IF res != 0 THEN
            RETURN res;
          END IF;

          LOOP
            IF lpair[2] = '' AND rpair[2] = '' THEN
              return 0;
            END IF;

            lpair := regexp_matches(lpair[2], '([^\\d]*)(.*)');
            rpair := regexp_matches(rpair[2], '([^\\d]*)(.*)');

            res := deb_version_cmp_al(lpair[1], rpair[1]);
            IF res != 0 THEN
              RETURN res;
            END IF;

            lpair := regexp_matches(lpair[2], '(\\d*)(.*)');
            rpair := regexp_matches(rpair[2], '(\\d*)(.*)');

            res := deb_version_cmp_num(lpair[1], rpair[1]);
            IF res != 0 THEN
              RETURN res;
            END IF;
          END LOOP;
        END
        $$ IMMUTABLE STRICT LANGUAGE plpgsql;
  ".freeze

  def self.up
    unless connection.adapter_name.downcase.include?('sqlite')
      execute FUNCTIONS
    end
  end

  def self.down
    unless connection.adapter_name.downcase.include?('sqlite')
      execute "
        DROP FUNCTION deb_version_cmp(text, text) CASCADE;
        DROP FUNCTION deb_version_cmp_al(text, text) CASCADE;
        DROP FUNCTION deb_version_cmp_num(text, text) CASCADE;
      "
    end
  end
end
