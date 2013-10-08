$ ->
  return unless $('#new_document')

  $('#files_uploader').fileupload
    dataType: 'json'
    maxFileSize: 10000000
    acceptFileTypes: /(\.|\/)(pdf|txt|doc|docx|html)$/i
    limitConcurrentUploads: 5

