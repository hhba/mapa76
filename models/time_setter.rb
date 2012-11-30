module TimeSetter
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

  def string_date
    if lemma =~ /(\d{1,2})\/(\d{1,2})\/(\d{4})/
      /(\d{1,2})\/(\d{1,2})\/(\d{4})/.match(lemma)[0]
    elsif lemma =~ /(\d{1,2})\/(\d{4})/
      '01/' + /(\d{1,2})\/(\d{4})/.match(lemma)[0]
    else
      nil
    end
  end

  def string_date?
    !string_date.nil?
  end

  def time
    string_date ? Time.parse(string_date) : nil
  end

  def timestamp
    time.to_i
  end
end
