class LegacyPromotionContentViewChanges < ActiveRecord::Migration
  def up
    return unless Katello.config.katello?
#1)  Create a "Default CVD"  which has all the content  in the library
#2) Publish a "Legacy View"
#3) For each Non Library env -> change the env's default CVV to point to the "Legacy View"
#4) Update every system whose cv is null and make em point to "Legacy View"
#5) Update every Activation Key whose cv is null and point em to "Legacy View"
#6) Change the  Org default view's CVE  to point to Legacy View  (Org default view's will not point to a CVE after this)
#7) Update repo create and clone methods to get the default env path from CVE as  opposed calculating based on env default view or not ....
#8) Auto publish on for Library default views
#9) Generate metadata for library views

    User.current = User.hidden.first

    Organization.all.each  do |org|
      # Create a "Default CVD"  which has all the content  in the library
      name = "Default Definition"
      if ContentViewDefinition.where(:name => name, :organization_id => org).count > 0
        name = name + "-#{SecureRandom.hex(4)}"
      end
      default_cvd = ContentViewDefinition.create!(:name => name, :organization => org)
      default_cvd.products = org.products
      default_cvd.save!

      # Publish a "Legacy View"
      name = "Legacy View"
      label = Util::Model.labelize(name)
      if ContentView.where(:label => label, :organization_id => org).count > 0
        name =  name + "-#{SecureRandom.hex(4)}"
        label = Util::Model.labelize(name)
      end

      default_cvd.publish(name, "View containing the Library Environment's content for #{org.name}",
                          label, :async => false, :notify => false)

      # For each Non Library env -> change the env's default CVV to point to the Legacy View"
      legacy_view = ContentView.where(:name => name, :content_view_definition_id => default_cvd).first
      org_default_view = org.default_content_view

      #create a version map to deal with the cvv version number allotments
      clause = "select id from environments where organization_id = #{org.id} order by created_at desc"
      env_ids = select_all(clause).collect{|row| row["id"].to_s}

      KTEnvironment.where(:library => false, :organization_id => org).each do |env|
        default_cvv = org.default_content_view.version(env)
        clause = %{
          INSERT INTO task_statuses (organization_id, created_at, state, task_type, updated_at, user_id, uuid, task_owner_id, task_owner_type)
                   VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        }

        params =  [org.id,
                    "now",
                     ::TaskStatus::Status::FINISHED,
                    TaskStatus::TYPES[:content_view_publish][:type],
                     "now",
                    User.current.id,
                    ::UUIDTools::UUID.random_create.to_s,
                    default_cvv.id,
                  default_cvv.class.name]

        insert(clause, nil, nil, nil, nil, params.collect{|item| [nil, item]})
        execute("update content_view_versions set content_view_id = #{legacy_view.id} where id = #{default_cvv.id}")
        version = env_ids.index(env.id.to_s)
        if version
          execute("update content_view_versions set version = #{version + 1} where id = #{default_cvv.id}")
        end
      end

      legacy_cvv = legacy_view.version(org.library)
      version = env_ids.index(org.library.id.to_s)
      if version
        execute("update content_view_versions set version = #{version + 1} where id = #{legacy_cvv.id}")
      end

      # Update every system whose cv is null and make em point to "Legacy View"
      clause = %{
        update systems set content_view_id = #{legacy_view.id} where
               (content_view_id is null) and id in (select s.id from systems as s
                    inner join environments as env  on env.id = s.environment_id
                    where env.organization_id = #{org.id})
      }
      execute(clause)

      # Update every Activation Key whose cv is null and point em to "Legacy View"
      execute("update activation_keys set content_view_id = #{legacy_view.id} where (content_view_id is null) and organization_id = #{org.id}")

      # Change the  Org default view's CVE  to point to Previous Environment's View
      # (Org default view's will not point to a CVE after this)
      clause = %{
        update content_view_environments set content_view_id = #{legacy_view.id} where
                 (content_view_id = #{org_default_view.id}) and environment_id not in
                    (select id from environments where library='t' and
                        organization_id=#{org.id})
      }

      execute(clause)

      #8) Auto publish on for Library default views

      clause = %{
        select distinct pulp_id, relative_path, unprotected from repositories where content_type='#{Repository::YUM_TYPE}' and environment_id in (select id from environments where library='t' and
                        organization_id=#{org.id})
      }

      data = ActiveRecord::Base.connection.select_all(clause)
      data.each do |repo_data|
        pulp_id = repo_data["pulp_id"]
        relative_path = repo_data["relative_path"]
        unprotected = repo_data["unprotected"] == "t"
        pulp_repo = Runcible::Extensions::Repository.retrieve_with_details(pulp_id)
        distro_items = pulp_repo[:distributors].select do |dis|
          dis["distributor_type_id"] == "yum_distributor"
        end

        distro_ids = distro_items .collect do |item|
          item[:id]
        end

        distro_ids.each do |distro_id|
          Runcible::Extensions::Repository.delete_distributor(pulp_id, distro_id)

          yum_distro =  Runcible::Extensions::YumDistributor.new(relative_path, (unprotected || false), true,
                                                                 {:protected => true})
          Runcible::Extensions::Repository.associate_distributor(pulp_id,
                                                                 "yum_distributor", yum_distro.config,
                                                                 "auto_publish" => true,
                                                                 "distributor_id" => distro_id)
        end
      end

    end

  end

  def down
  end
end
