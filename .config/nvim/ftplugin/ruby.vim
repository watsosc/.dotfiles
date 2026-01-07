" Ensure b:undo_ftplugin exists before plugin after/ftplugins (e.g. vim-rails) append to it
if !exists('b:undo_ftplugin')
  let b:undo_ftplugin = ''
endif
