class CheckedBooleanInput < SimpleForm::Inputs::BooleanInput
  
private

  def build_check_box(unchecked_value = unchecked_value, checked = false)
    @builder.check_box(attribute_name, {checked: checked}.merge(input_html_options), checked_value, unchecked_value)
  end

  def build_check_box_without_hidden_field
    build_check_box(nil, true)
  end
end
