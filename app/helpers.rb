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
        markup="<span class='address popup' id='#{n.fragment_id}'><span class='where'>#{n}</span></span>"
      end
      ret.gsub!(n,markup)
    }
    if ret.scan(/\n\w+\n/).length < 5
      ret.gsub!("\n","<br />")
    end
    ret
  end

  def store_file(opts)
    filename = opts[:filename].to_s.gsub(' ', '_')
    dir = File.join(Padrino.root, 'public', DOCUMENTS_DIR)
    path = File.join(dir, filename)
    FileUtils.mkdir_p(dir)
    File.open(path, 'wb') { |f| f.write(opts[:tempfile].read) }
    return filename
  end

  def documents_name(documents, document_ids)
    output = ""
    document_ids.each do |id|
      output << link_to(document_from_id(documents, id), "/documents/#{id}") + " | "
    end
    output[0..-3]
  end

  def document_from_id(documents, id)
    index = documents.index { |doc|doc.id == id }
    puts documents[index].heading
    documents[index].heading
  end

  def original_file_url(document)
    "/#{DOCUMENTS_DIR}/#{CGI.escape(document.original_file)}" if document.original_file
  end

  def thumbnail_url(document)
    "/#{THUMBNAILS_DIR}/#{CGI.escape(document.thumbnail_file)}" if document.thumbnail_file
  end

  def thumbnail_tag(document, opts={})
    url = document.thumbnail_file ? thumbnail_url(document) : image_path('thumbnail_placeholder.png')
    img = image_tag(url, opts)
    content_tag :div, img, :class => :thumbnail
  end

  def paragraph_with_tagged_named_entities(paragraph)
    html = ''
    #cur_pos = 0
    cur_pos = paragraph.pos
    document_content = paragraph.content

    paragraph.named_entities.excludes(:ne_class => :addresses).each do |named_entity|
      #ne_pos = named_entity.pos - paragraph.pos
      #html << paragraph.content[cur_pos ... ne_pos]
      ne_pos = named_entity.pos
      html << document_content[cur_pos ... ne_pos]
      html << "<span class=\"ne #{named_entity.ne_class}\" data-id=\"#{named_entity.id}\">#{named_entity.text}</span>"
      cur_pos = ne_pos + named_entity.text.size
    end
    #html << paragraph.content[cur_pos .. -1].to_s
    html << document_content[cur_pos .. paragraph.pos + paragraph.content.size - 1].to_s
    html << Document::PARAGRAPH_SEPARATOR
  end

  def page_html(page)
    text_lines = page.text_lines.map do |text_line|
      content_tag(:p, text_line.text.gsub(" ", "&nbsp;"), {
        :class => "fs#{text_line.fontspec_id}",
        :style => "top: #{text_line.top}px; left: #{text_line.left}px; width: #{text_line.width}px;"
      })
    end
    content_tag(:div, text_lines.join("\n"), {
      :class => "page",
      :style => "width: #{page.width}px; height: #{page.height}px"
    })
  end
end
