#= require active_admin/base
#= require activeadmin_addons/all
#= require tinymce
$(document).ready ->
  tinyMCE.init
    mode: "textareas"
    theme: "modern"
    editor_selector: "tinymce"
  return