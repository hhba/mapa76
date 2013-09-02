require "tire/index"

module Tire
  class Index
    def get_id_from_document_with_object_id_fix(document)
      get_id_from_document_without_object_id_fix(document).try(:to_s)
    end
    alias_method_chain :get_id_from_document, :object_id_fix
  end
end
