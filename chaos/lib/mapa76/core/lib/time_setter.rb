module TimeSetter
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
