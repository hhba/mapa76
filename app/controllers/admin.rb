require "json"
require "docsplit"
require "open-uri"
require "tempfile"


Alegato.controllers :admin do
  layout :admin

  get :index do
    @docs = Document.all
    render "admin/doc_list" 
  end

  get :import do
    render "admin/import"
  end

  put :import do
#    {"_method"=>"PUT", "title"=>"", "url"=>"", "text"=>"", "file"=>{:filename=>"additional_account_specific_terms_and_conditions.pdf", :type=>"application/pdf", :name=>"file", :tempfile=>#<File:/tmp/RackMultipart20110917-14082-e6w8ps>, :head=>"Content-Disposition: form-data; name=\"file\"; filename=\"additional_account_specific_terms_and_conditions.pdf\"\r\nContent-Type: application/pdf\r\n"}}
    puts params
    if not params[:text].empty?
      text = params[:text]
    elsif (params[:file] and params[:file][:tempfile])  or not params[:url].empty?
      if not params[:url].empty?
        require "httpi"
        req = HTTPI.get(params[:url])
        type = req.headers["Content-type"]
        data = req.body
      elsif params[:file]
        type = params[:file][:type]
        data = params[:file][:tempfile].read
      end

      if type  == "application/pdf"
        text = Docsplit.clean_text(Docsplit.extract_text_from_pdf_str(data))
        #title = Docsplit.extract_title_from_pdf_str(data)
      elsif type  == "text/plain"
        text = data
        title = params[:title]
      else
        raise "Unknown filetype: #{type}" 
      end
    end
    @doc = Document.new :title => params[:title]
    @doc.data = text
    if @doc.save
      redirect url_for(:doc_admin_index, :doc_id => @doc.id)
    else
      "Error guardando"
    end
  end

  get :person, :with => [:id] do
    if params[:id].to_i == 0
      @persons = Person.filter_by_name(BSON::ObjectId((params[:id]))).all
    else
      @persons = [Person[params[:id]]]
    end
    render "admin/person"
  end

  get :context do
    if params[:fragment_id]
      data=params[:fragment_id].match(/frag:doc=([^:]+):([0-9]+)-([0-9]+)/)
      puts params
      doc_id=data[1]
      pos_start=data[2]
      pos_end=data[3]
    else
      doc_id=params[:doc_id]
      pos_start=params[:start]
      pos_end=params[:end]
    end

    params[:around] ||= 1000

    case params[:action].to_i
      when 1 # more
          pos_start   = pos_start.to_i - params[:around].to_i
          pos_start   = 0 if pos_start < 0
          pos_end     = pos_end.to_i + params[:around].to_i
      when 2 # less
          pos_start   = pos_start.to_i + params[:around].to_i
          pos_start   = 0 if pos_start < 0
          pos_end     = pos_end.to_i - params[:around].to_i
      when 3 # down
          pos_start   = pos_start.to_i + params[:around].to_i
          pos_end     = pos_end.to_i + params[:around].to_i
      when 4 # up
          pos_start   = pos_start.to_i - params[:around].to_i
          pos_start   = 0 if pos_start < 0
          pos_end     = pos_end.to_i - params[:around].to_i
    end

    fragment=Document.find(doc_id).fragment(pos_start,pos_end)
    r={:fragment_id => fragment.fragment_id, :text => markup_fragment(fragment), :prev_fragment_id => params[:fragment_id]}.to_json
    r
  end

  post :classify_name do
    r=false
    if params[:name] and params[:training]
      Text::PersonName.train(params[:training],params[:name])
      r=Text::PersonName.training_save
    end
    r.to_json
  end

end
