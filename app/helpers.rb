# Helper methods defined here can be accessed in any controller or view in the application
require "active_support/core_ext/array/uniq_by"
Alegato.helpers do
  def markup_fragment(fragment)
    fr = fragment.extract()
    ret = fragment.dup
    person_names = fr.person_names
    dates = fr.dates
    addresses = fr.addresses(env[:milestones] ||= Milestone.where_list)

    person_names.uniq_by{|w| w.to_s.downcase.strip}.find_all(&:classified_good?).sort_by{|n| n.length}.reverse.each{|n|
      ret.gsub!(n,"<span person_id='#{Person.get_id_by_name(n)}' class='popup person name #{ActiveSupport::Inflector.parameterize(n)}' frag='#{n.fragment_id}'>#{n}</span>")
    }
    dates.uniq.sort_by{|n| n.to_s.length}.reverse.each{|n|
      ret.gsub!(n.context(0),"<time class='date popup' datetime='#{n.to_s('')}' id='#{n.fragment_id}'>#{n.context(0)}</time>")
    }
    addresses.uniq.each{|n|
      if n.geocode
        lat,lon = n.geocode.ll.split(",",2)
        markup="<span class='address popup' frag='#{n.fragment_id}'><span class='geo' style='display:none' itemprop='geo' itemscope='itemscope' itemtype='http://data-vocabulary.org/Geo/'><abbr class='latitude' itemprop='latitude' title='#{lat}'>#{lat}</abbr> <abbr class='longitude' itemprop='longitude' title='#{lon}'>#{lon}</abbr></span><span class='where'>#{n}</span></span>"
      else
        markup="<span class='address' id='#{n.fragment_id}'><span class='where'>#{n}</span></span>"
      end
      ret.gsub!(n,markup)
    }
    if ret.scan(/\n\w+\n/).length < 5
      ret.gsub!("\n","<br />")
    end
    ret
  end
end
