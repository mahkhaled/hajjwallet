module Spree
  module Api
    module V1
      class ProductsController < Spree::Api::BaseController
        def index
          if params[:ids]
            @products = product_scope.where(id: params[:ids].split(',').flatten)
          else
            @products = product_scope.ransack(params[:q]).result
          end

          @products = @products.distinct.page(params[:page]).per(params[:per_page])
          expires_in 15.minutes, public: true
          headers['Surrogate-Control'] = "max-age=#{15.minutes}"
          respond_with(@products)
        end

        def show
          @product = find_product(params[:id])
          expires_in 15.minutes, public: true
          headers['Surrogate-Control'] = "max-age=#{15.minutes}"
          headers['Surrogate-Key'] = 'product_id=1'
          respond_with(@product)
        end

        # Takes besides the products attributes either an array of variants or
        # an array of option types.
        #
        # By submitting an array of variants the option types will be created
        # using the *name* key in options hash. e.g
        #
        #   product: {
        #     ...
        #     variants: {
        #       price: 19.99,
        #       sku: "hey_you",
        #       options: [
        #         { name: "size", value: "small" },
        #         { name: "color", value: "black" }
        #       ]
        #     }
        #   }
        #
        # Or just pass in the option types hash:
        #
        #   product: {
        #     ...
        #     option_types: ['size', 'color']
        #   }
        #
        # By passing the shipping category name you can fetch or create that
        # shipping category on the fly. e.g.
        #
        #   product: {
        #     ...
        #     shipping_category: "Free Shipping Items"
        #   }
        #
        def new; end

        def create
          authorize! :create, Product
          params[:product][:available_on] ||= Time.current
          set_up_shipping_category

          options = { variants_attrs: variants_params, options_attrs: option_types_params }
          @product = Core::Importer::Product.new(nil, product_params, options).create

          if @product.persisted?
            respond_with(@product, status: 201, default_template: :show)
          else
            invalid_resource!(@product)
          end
        end

        def update
          @product = find_product(params[:id])
          authorize! :update, @product

          options = { variants_attrs: variants_params, options_attrs: option_types_params }
          @product = Core::Importer::Product.new(@product, product_params, options).update

          if @product.errors.empty?
            respond_with(@product.reload, status: 200, default_template: :show)
          else
            invalid_resource!(@product)
          end
        end

        def destroy
          @product = find_product(params[:id])
          authorize! :destroy, @product
          @product.destroy
          respond_with(@product, status: 204)
        end

        def product_recommendations
          require 'recombee_api_client'
          include RecombeeApiClient
          
          client = RecombeeClient('hajjwallet', 'jfio458jwflkwekhefjk32nksdjfw')

          @product = find_product(params[:id])
          
          # Get 5 recommendations for current user, who is currently viewing this product
          recommended = client.send(RecommendItemsToItem.new("item-#{@product.id}", "user-#{current_user.id}", 5) )
          puts "Recommended items: #{recommended}"
          
          respond_with(recommended)
        end

        def user_recommendations
          require 'recombee_api_client'
          include RecombeeApiClient
          
          client = RecombeeClient('hajjwallet', 'jfio458jwflkwekhefjk32nksdjfw')

          # Get 5 recommendations for current user
          recommended = client.send(RecommendItemsToUser.new( "user-#{current_user.id}", 5) )
          puts "Recommended items: #{recommended}"
          
          respond_with(recommended)
        end

        private

        def product_params
          params.require(:product).permit(permitted_product_attributes)
        end

        def variants_params
          variants_key = if params[:product].key? :variants
                           :variants
                         else
                           :variants_attributes
          end

          params.require(:product).permit(
            variants_key => [permitted_variant_attributes, :id]
          ).delete(variants_key) || []
        end

        def option_types_params
          params[:product].fetch(:option_types, [])
        end

        def set_up_shipping_category
          if shipping_category = params[:product].delete(:shipping_category)
            id = ShippingCategory.find_or_create_by(name: shipping_category).id
            params[:product][:shipping_category_id] = id
          end
        end
      end
    end
  end
end
