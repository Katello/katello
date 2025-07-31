class KatelloRecreateEvrConstructs < ActiveRecord::Migration[6.1]
  def fix_installed_package_dupes
    # Remove duplicate installed packages and host installed packages.
    duplicated_nvreas = ::Katello::InstalledPackage.group(:nvrea).having('count(*) > 1').pluck(:nvrea)
    duplicated_nvreas.each do |nvrea|
      packages_relation = ::Katello::InstalledPackage.where(nvrea: nvrea).order(:id)
      original_package = packages_relation.first
      duplicate_package_ids = packages_relation.offset(1).pluck(:id)
      hosts_with_original_package = ::Katello::HostInstalledPackage.where(installed_package_id: original_package.id).pluck(:host_id)
      if hosts_with_original_package.any?
        ::Katello::HostInstalledPackage.where(host_id: hosts_with_original_package, installed_package_id: duplicate_package_ids).delete_all
      end
      ::Katello::HostInstalledPackage.where(installed_package_id: duplicate_package_ids).update_all(installed_package_id: original_package.id)
      ::Katello::InstalledPackage.where(id: duplicate_package_ids).delete_all
    end
  end

  def up
    fix_installed_package_dupes

    if !extension_enabled?('evr')
      return
    else
      execute <<~SQL
        DROP EXTENSION evr CASCADE;
      SQL

      execute <<~SQL
              create type evr_array_item as (
          n       NUMERIC,
          s       TEXT
        );

        create type evr_t as (
          epoch INT,
          version evr_array_item[],
          release evr_array_item[]
        );

        CREATE FUNCTION evr_trigger() RETURNS trigger AS $$
          BEGIN
            NEW.evr = (select ROW(coalesce(NEW.epoch::numeric,0),
                                  rpmver_array(coalesce(NEW.version,'empty'))::evr_array_item[],
                                  rpmver_array(coalesce(NEW.release,'empty'))::evr_array_item[])::evr_t);
            RETURN NEW;
          END;
        $$ language 'plpgsql';

        create or replace FUNCTION empty(t TEXT)
        	RETURNS BOOLEAN as $$
        	BEGIN
        		return t ~ '^[[:space:]]*$';
        	END;
        $$ language 'plpgsql';

        create or replace FUNCTION isalpha(ch CHAR)
          RETURNS BOOLEAN as $$
          BEGIN
            if ascii(ch) between ascii('a') and ascii('z') or
                ascii(ch) between ascii('A') and ascii('Z')
            then
              return TRUE;
            end if;
            return FALSE;
          END;
        $$ language 'plpgsql';

        create or replace FUNCTION isalphanum(ch CHAR)
        	RETURNS BOOLEAN as $$
        	BEGIN
        		if ascii(ch) between ascii('a') and ascii('z') or
        			ascii(ch) between ascii('A') and ascii('Z') or
        			ascii(ch) between ascii('0') and ascii('9')
        		then
        			return TRUE;
        		end if;
        		return FALSE;
        	END;
        $$ language 'plpgsql';

        create or replace function isdigit(ch CHAR)
        	RETURNS BOOLEAN as $$
        	BEGIN
        	  if ascii(ch) between ascii('0') and ascii('9')
        	  then
        		return TRUE;
        	  end if;
        	  return FALSE;
        	END ;
        $$ language 'plpgsql';

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

      SQL

      add_column :katello_rpms, :evr, :evr_t
      add_column :katello_installed_packages, :evr, :evr_t

      execute <<-SQL
        update katello_rpms SET evr = (ROW(coalesce(epoch::numeric,0),
                                           rpmver_array(coalesce(version,'empty'))::evr_array_item[],
                                           rpmver_array(coalesce(release,'empty'))::evr_array_item[])::evr_t);

        update katello_installed_packages SET evr = (ROW(coalesce(epoch::numeric,0),
                                                         rpmver_array(coalesce(version,'empty'))::evr_array_item[],
                                                         rpmver_array(coalesce(release,'empty'))::evr_array_item[])::evr_t);
      SQL

      add_index :katello_rpms, [:name, :arch, :evr]

      create_trigger :evr_insert_trigger_katello_rpms, on: :katello_rpms
      create_trigger :evr_update_trigger_katello_rpms, on: :katello_rpms
      create_trigger :evr_insert_trigger_katello_installed_packages, on: :katello_installed_packages
      create_trigger :evr_update_trigger_katello_installed_packages, on: :katello_installed_packages
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
