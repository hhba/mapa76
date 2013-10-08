$ ->
  return unless $('#new_document')

  $('#files_uploader').fileupload
    dataType: 'json'
    maxFileSize: 10000000
    acceptFileTypes: /(\.|\/)(pdf|txt|doc|docx|html)$/i
    #limitConcurrentUploads: 5
    #progressall: (e, data) ->
      #progress = parseInt(data.loaded / data.total * 100, 10)
      #$('#progress .bar').css "width", "#{progress}%"
    #add: (e, data) ->

