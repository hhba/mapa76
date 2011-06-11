# Helper methods defined here can be accessed in any controller or view in the application

Alegato.helpers do
  # def simple_helper_method
  #  ...
  # end
  def markup_fragment(fragment)
    fr = fragment.extract()
    ret = fragment.dup
    person_names = fr.person_names
    dates = fr.dates
    addresses = fr.addresses

    person_names.find_all(&:classified_good?).sort_by{|n| n.length}.reverse.each{|n|
      ret.gsub!(n,"<span class='name #{ActiveSupport::Inflector.parameterize(n)}' id='#{n.fragment_id}'>#{n}</span>")
    }
    dates.each{|n|
      ret.gsub!(n.context(0),"<time class='date' datetime='#{n.to_s}' id='#{n.fragment_id}'>#{n.context(0)}</time>")
    }
    addresses.each{|n|
      if n.geocode
        lat,lon = n.geocode.ll.split(",",2)
        markup="<span class='address' id='#{n.fragment_id}'><span class='geo' style='display:none' itemprop='geo' itemscope='itemscope' itemtype='http://data-vocabulary.org/Geo/'>
        <abbr class='latitude' itemprop='latitude' title='#{lat}'>#{lat}</abbr>
        <abbr class='longitude' itemprop='longitude' title='#{lon}'>#{lon}</abbr>
        </span>#{n}</span>"
        ret.gsub!(n,markup)
      end
    }
    ret.gsub!("\n","<br />")
    ret
  end
end
