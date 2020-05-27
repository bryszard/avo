require_relative 'field'

module Avocado
  module Fields
    class BelongsToField < Field
      attr_accessor :searchable
      attr_accessor :relation_method

      def initialize(name, **args, &block)
        @defaults = {
          component: 'belongs-to-field',
        }

        @searchable = args[:searchable] == true ? true : false
        @relation_method = name.to_s.parameterize.underscore

        super(name, **args, &block)
      end

      def hydrate_resource(model, resource, view)
        fields = {}

        return fields if model_or_class(model) == 'class'

        fields[:searchable] = @searchable
        fields[:is_relation] = true
        fields[:database_field_name] = model.class.reflections[@relation_method].foreign_key
        target_resource = App.get_resources.find { |r| r.class == "Avocado::Resources::#{name}".safe_constantize }

        relation_model = model.public_send(@relation_method)

        if relation_model.present?
          relation_model = model.public_send(@relation_method)
          fields[:value] = relation_model[target_resource.title] if relation_model.present?
          fields[:select_value] = relation_model[:id] if relation_model.present?
          fields[:link] = Avocado::Resources::Resource.show_path(relation_model)
        end

        fields[:options] = []
        if view == :edit
          if self.searchable
            fields[:model] = relation_model
          else
            fields[:options] = target_resource.model.select(:id, target_resource.title).all.map do |model|
              {
                value: model.id,
                label: model[target_resource.title]
              }
            end
          end
        end

        fields[:resource_name_plural] = target_resource.resource_name_plural

        fields
      end
    end
  end
end