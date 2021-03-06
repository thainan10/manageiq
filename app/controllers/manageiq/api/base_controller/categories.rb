module ManageIQ
  module API
    class BaseController
      module Categories
        #
        # Categories Collection Supporting Methods
        #
        #
        def show_categories
          request_additional_attributes
          show_generic
        end

        def edit_resource_categories(type, id, data = {})
          raise BaseController::Forbidden if Category.find(id).read_only?
          request_additional_attributes
          edit_resource(type, id, data)
        end

        def delete_resource_categories(type, id, data = {})
          raise BaseController::Forbidden if Category.find(id).read_only?
          delete_resource(type, id, data)
        end

        private

        def request_additional_attributes
          @additional_attributes = %w(name)
        end
      end
    end
  end
end
