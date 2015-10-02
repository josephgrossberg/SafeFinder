module SafeFinder
  class NullObjectGenerator
    attr_reader :original_class, :original_class_name, :null_class, :setted_columns

    def initialize(original_class)
      @original_class = original_class
      @original_class_name = original_class.to_s
      @null_class = create_null_class
      @setted_columns = original_class.null_object_attributes
    end

    def generate
      set_attributes
      set_methods
      null_class.new
    end

    private

    def create_null_class
      Object.const_set("Null#{original_class_name}", Class.new(NullObject))
    end

    def get_attributes
      original_class.columns.inject({}) do |result, column|
        result[column.name] = get_value(column)
        result
      end
    end

    # I want to support default value here.
    # But column object's default value is string, and needs some mechanism be to converted into ruby's type
    def get_value(column)
      if value = setted_columns[column.name.to_sym]
        value
      end
    end

    def set_methods
      methods = original_class.null_object_methods
      null_class.class_eval do
        methods.each do |key, value|
          define_method key, value
        end
      end
    end

    def set_attributes
      attributes = get_attributes
      null_class.class_eval do
        attributes.each do |key, value|
          define_method key do
            value
          end
        end
      end
    end
  end
end
