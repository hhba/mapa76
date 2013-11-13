class PrettyFormBuilder < ActionView::Helpers::FormBuilder
  def pretty_text_field(method, options={})
    input = if @object.errors.messages[method]
      options[:class] = 'input-error'
      @template.text_field(@object_name, method, objectify_options(options)) +
        @template.content_tag(:label, error_message(method), class: 'msj')
    else
      @template.text_field(@object_name, method, objectify_options(options))
    end
    @template.content_tag(:div, input, class: 'input-item')
  end

  def pretty_text_area(method, options={})
    input = @template.text_area(@object_name, method, objectify_options(options))
    @template.content_tag(:div, input, class: 'input-item')
  end

private

  def error_message(method)
    if @object.errors.messages[method].instance_of?(Array)
      @object.errors.messages[method][0]
    else
      @object.errors.messages[method]
    end
  end
end
