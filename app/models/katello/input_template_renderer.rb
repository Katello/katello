class InputTemplateRenderer
  include UnattendedHelper

  def errata(id)
    Katello::Erratum.with_identifiers(id).map(&:attributes).first.slice!('created_at', 'updated_at')
  end
end
