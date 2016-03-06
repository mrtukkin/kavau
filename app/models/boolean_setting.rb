class BooleanSetting < Setting
  def value
    ActiveRecord::Type::Boolean.new.type_cast_from_database(self[:value]) || false
  end

  def form_field_partial
    'settings/boolean_setting_field'
  end
end


