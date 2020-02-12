create or replace FUNCTION rpmver_array (string1 IN VARCHAR)
	RETURNS evr_array_item[] as $$
	declare
		str1 VARCHAR := string1;
		digits VARCHAR(10) := '0123456789';
		lc_alpha VARCHAR(27) := 'abcdefghijklmnopqrstuvwxyz';
		uc_alpha VARCHAR(27) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
		alpha VARCHAR(54) := lc_alpha || uc_alpha;
		one VARCHAR;
		isnum BOOLEAN;
		ver_array evr_array_item[] := ARRAY[]::evr_array_item[];
	BEGIN
		if str1 is NULL
		then
			RAISE EXCEPTION 'VALUE_ERROR.';
		end if;

		one := str1;
		<<segment_loop>>
		while one <> ''
		loop
			declare
				segm1 VARCHAR;
				segm1_n NUMERIC := 0;
			begin
				-- Throw out all non-alphanum characters
				while one <> '' and not isalphanum(one)
				loop
					one := substr(one, 2);
				end loop;
				str1 := one;
				if str1 <> '' and isdigit(str1)
				then
					str1 := ltrim(str1, digits);
					isnum := true;
				else
					str1 := ltrim(str1, alpha);
					isnum := false;
				end if;
				if str1 <> ''
				then segm1 := substr(one, 1, length(one) - length(str1));
				else segm1 := one;
				end if;

				if segm1 = '' then return ver_array; end if; /* arbitrary */
				if isnum
				then
					segm1 := ltrim(segm1, '0');
					if segm1 <> '' then segm1_n := segm1::numeric; end if;
					segm1 := NULL;
				else
				end if;
				ver_array := array_append(ver_array, (segm1_n, segm1)::evr_array_item);
				one := str1;
			end;
		end loop segment_loop;

		return ver_array;
	END ;
$$ language 'plpgsql';
