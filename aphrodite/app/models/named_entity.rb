class NamedEntity < Citation
  # FIXME this should be a helper
  def to_time_setter
    {
      :date => string_date,
      :display_date => string_date,
      :description => context,
      :link => "/documents/#{document_id}/comb##{page_num}",
      :series => "",
      :html => "",
      :timestamp => timestamp
    }
  end

  def href
    # I'm sorry for this:
    Rails.application.routes.url_helpers.comb_document_url(:id => document_id, :host => "mapa76.info", :anchor => page_num)
  end
end
