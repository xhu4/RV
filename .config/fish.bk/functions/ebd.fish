# Defined via `source`
function ebd --wraps='$EDITOR $OMF_CONFIG/key_bindings.fish' --description 'alias ebd=$EDITOR $OMF_CONFIG/key_bindings.fish'
  $EDITOR $OMF_CONFIG/key_bindings.fish $argv; 
end
