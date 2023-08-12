class Avo::Menu::Resource < Avo::Menu::BaseItem
  extend Dry::Initializer

  option :resource
  option :label, optional: true
  option :params, optional: true

  def parsed_resource
    guessed_resource = Avo::App.guess_resource resource.to_s

    if params.present?
      guessed_resource.params ||= {}
      guessed_resource.params.merge!(params: params)
    end

    guessed_resource
  end

  def entity_label
    parsed_resource.navigation_label
  end
end
