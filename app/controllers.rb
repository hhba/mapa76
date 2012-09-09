# encoding: utf-8

Alegato.controllers  do
  get :test do
    render :test
  end

  get :index do
    @persons = if params[:ids]
      Person.find(params[:ids].split(','))
    else
      Person.find(Milestone.all.map(&:person_id).uniq)
    end

    render :index
  end

  get :ccd do
    render :ccd
  end

  get :timeline_json do
    persons = Person.find(params[:ids].split(","))
    t = {}
    t[:dateTimeFormat] = "iso8601"
    t[:"wiki-section"] = "#{persons.map(&:name).join(", ")}"
    t[:events] = persons.map do |p|
      p.milestones.map do |m|
        r = {}
        r[:start] = "#{m.date_from_range.begin.iso8601}"
        if m.date_to_range
          r[:end] = "#{m.date_to_range.last.iso8601}"
        end
        r[:durationEvent] = !!(m.date_from_range && m.date_to_range)
        r[:title] = "#{p.name} - #{m.what}"
        r[:description] =  "#{p.name} - #{m.what} - #{m.where}"
        r
      end
    end.flatten

    render t, :layout => false
  end

  get :entities do
    not_found
  end

  get :facts do
    not_found
  end

  get :projects do
    not_found
  end
end
