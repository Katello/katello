class UpdateRepoEnvironmentProductColumns < ActiveRecord::Migration

  class EnvironmentProduct < ActiveRecord::Base
  end

  class Repository < ActiveRecord::Base
  end

  def up
    EnvironmentProduct.all.each do |env_prod|
      [:product_id, :environment_id].each do |attr|
        if (val = env_prod.send(attr))
          Repository.update_all("#{attr.to_s} = #{val}",
                                "environment_product_id = #{env_prod.id}"
                               )
        end
      end
    end
  end

  def down
    Repository.all.each do |repo|
      env_prod = EnvironmentProduct.find_or_create_by_environment_id_and_product_id(
          repo.environment_id,
          repo.product_id
        )

      repo.update_attribute(:environment_product_id, env_prod.id)
    end
  end
end
