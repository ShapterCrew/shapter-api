module Funnelable
  extend ActiveSupport::Concern

  included do 

    def validate_funnel_format(attr)

      return unless funnel = self.send(attr)
      
      funnel.each.with_index do |h,i|
        if h.is_a? Hash
          errors.add(:field, "#{attr}[#{i}] should have name key") unless h.has_key?("name") or h.has_key?(:name)
          errors.add(:field, "#{attr}[#{i}] should have tag_ids key") unless h.has_key?("tag_ids") or h.has_key?(:tag_ids)
          if h.has_key?("default_types") and !!h["default_types"]
            errors.add(:field, "#{attr}[#{i}] default_types should be an array") unless h["default_types"].is_a?(Array)
          end
        else
          errors.add(:field, "#{attr}[#{i}] should be a hash")
        end
      end
    end

  end

  module ClassMethods
    def funnel_for(attr_name)
      self.send(:field, attr_name, type: Array)
      self.send(:validate) do |obj|
        obj.validate_funnel_format(attr_name)
      end
    end
  end

end
